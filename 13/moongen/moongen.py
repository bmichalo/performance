# Copyright 2016 Red Hat Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""
Moongen Traffic Generator Model
"""

# python imports
import logging
from collections import OrderedDict
import subprocess
import re
# import sys


# VSPerf imports
from conf import settings
from core.results.results_constants import ResultsConstants
from tools.pkt_gen.trafficgen.trafficgenhelper import (
    TRAFFIC_DEFAULTS,
    merge_spec)
from tools.pkt_gen.trafficgen.trafficgen import ITrafficGenerator



class MoonGenResultsConstants(object):
    """
    MoonGen results class
    """
    #
    # Results
    #
    TX_FRAMES = 'tx_frames'
    RX_FRAMES = 'rx_frames'
    FRAME_LOSS_COUNT = 'frame_loss_count'
    FRAME_LOSS_PERCENT = 'frame_loss_percent'
    RX_MPPS = 'rx_mpps'
    TX_MPPS = 'tx_mpps'
    #
    # Test Parameters
    #
    START_RATE = 'start_rate'
    NUMBER_OF_STREAMS = 'number_of_streams'
    FRAME_SIZE = 'frame_size'



class Moongen(ITrafficGenerator):
    """
    Moongen Traffic generator wrapper
    """
    _traffic_defaults = TRAFFIC_DEFAULTS.copy()
    _logger = logging.getLogger(__name__)

    def __init__(self):
        self._logger.info("In moongen __init__ method")
        self._params = {}

    @property
    def traffic_defaults(self):
        """Default traffic values.

        These can be expected to be constant across traffic generators,
        so no setter is provided. Changes to the structure or contents
        will likely break traffic generator implementations or tests
        respectively.
        """
        self._logger.info("In moongen traffic_defaults method")
        return self._traffic_defaults

    @staticmethod
    def _create_moongen_cfg_file(traffic, duration=60, acceptable_loss_pct=1):
        """
        Create the MoonGen configuration file from VSPERF's traffic profile
        """
        moongen_host_ip_addr = settings.getValue('TRAFFICGEN_MOONGEN_HOST_IP_ADDR')
        moongen_base_dir = settings.getValue('TRAFFICGEN_MOONGEN_BASE_DIR')
        moongen_user = settings.getValue('TRAFFICGEN_MOONGEN_USER')
        moongen_ports = settings.getValue('TRAFFICGEN_MOONGEN_PORTS')
        print(traffic)
        print("traffic['frame_rate'] = %s" % str(traffic['frame_rate']))
        print("traffic['multistream'] = %s" % str(traffic['multistream']))
        print("traffic['stream_type'] = %s" % str(traffic['stream_type']))
        print("traffic['l2']['srcmac'] = %s" % str(traffic['l2']['srcmac']))
        print("traffic['l2']['dstmac'] = %s" % str(traffic['l2']['dstmac']))
        print("traffic['l3']['proto'] = %s" % str(traffic['l3']['proto']))
        print("traffic['l3']['srcip'] = %s" % str(traffic['l3']['srcip']))
        print("traffic['l3']['dstip'] = %s" % str(traffic['l3']['dstip']))
        print("traffic['l4']['srcport'] = %s" % str(traffic['l4']['srcport']))
        print("traffic['l4']['dstport'] = %s" % str(traffic['l4']['dstport']))
        print("traffic['vlan']['enabled'] = %s" % str(traffic['vlan']['enabled']))
        print("traffic['vlan']['id'] = %s" % str(traffic['vlan']['id']))
        print("traffic['vlan']['priority'] = %s" % str(traffic['vlan']['priority']))
        print("traffic['vlan']['cfi'] = %s" % str(traffic['vlan']['cfi']))
        print(traffic['l2']['framesize'])
        out_file = open("opnfv-vsperf-cfg.lua", "wt")
        out_file.write("VSPERF {\n")
        out_file.write("testType = \"throughput\",\n")
        out_file.write("runBidirec = " + traffic['bidir'].lower() + ",\n")
        out_file.write("searchRunTime = " + str(duration) + ",\n")
        out_file.write("validationRunTime = " + str(duration) + ",\n")
        out_file.write("acceptableLossPct = " + str(acceptable_loss_pct) + ",\n")
        out_file.write("frameSize = " + str(traffic['l2']['framesize']) + ",\n")
        out_file.write("ports = " + str(moongen_ports) + ",\n")
        out_file.write("startRate = 4\n")
        out_file.write("}" + "\n")
        out_file.close()

        copy_moongen_cfg = "scp opnfv-vsperf-cfg.lua " + moongen_user + "@" + \
                            moongen_host_ip_addr + ":" + moongen_base_dir + \
                            "/. && rm opnfv-vsperf-cfg.lua"
        find_moongen = subprocess.Popen(copy_moongen_cfg, shell=True, stderr=subprocess.PIPE)
        output, error = find_moongen.communicate()

        if error:
            print(output)
            print(error)
            raise RuntimeError('MOONGEN: Error copying configuration file')

        return


    def connect(self):
        self._logger.info("MOONGEN:  In MoonGen connect method...")
        moongen_host_ip_addr = settings.getValue('TRAFFICGEN_MOONGEN_HOST_IP_ADDR')
        moongen_base_dir = settings.getValue('TRAFFICGEN_MOONGEN_BASE_DIR')
        moongen_user = settings.getValue('TRAFFICGEN_MOONGEN_USER')

        if moongen_host_ip_addr:
            print(moongen_host_ip_addr)
            cmd_ping = "ping -c1 " + moongen_host_ip_addr
        else:
            raise RuntimeError('MOONGEN: MoonGen host not defined')

        ping = subprocess.Popen(cmd_ping, shell=True, stderr=subprocess.PIPE)
        output, error = ping.communicate()
        print(output)

        if error:
            raise RuntimeError('MOONGEN: Cannot ping MoonGen host at %s' % moongen_host_ip_addr)


        connect_moongen = "ssh " + moongen_user + "@" + moongen_host_ip_addr
        cmd_find_moongen = connect_moongen + " ls " + moongen_base_dir + "/examples/opnfv-vsperf.lua"

        find_moongen = subprocess.Popen(cmd_find_moongen, shell=True, stderr=subprocess.PIPE)
        output, error = find_moongen.communicate()

        if error:
            raise RuntimeError('MOONGEN: Cannot locate MoonGen program at %s within %s' \
                    % (moongen_host_ip_addr, moongen_base_dir))

        self._logger.info("MOONGEN: MoonGen host successfully found...")

    def disconnect(self):
        """Disconnect from the traffic generator.

        As with :func:`connect`, this function is optional.


        Where implemented, this function should raise an exception on
        failure.

        :returns: None
        """
        self._logger.info("MOONGEN: In moongen disconnect method")

    def send_burst_traffic(self, traffic=None, numpkts=100, duration=20):
        """Send a burst of traffic.

        Send a ``numpkts`` packets of traffic, using ``traffic``
        configuration, with a timeout of ``time``.

        Attributes:
        :param traffic: Detailed "traffic" spec, i.e. IP address, VLAN tags
        :param numpkts: Number of packets to send
        :param duration: Time to wait to receive packets

        :returns: dictionary of strings with following data:
            - List of Tx Frames,
            - List of Rx Frames,
            - List of Tx Bytes,
            - List of List of Rx Bytes,
            - Payload Errors and Sequence Errors.
        """
        self._logger.info("In moongen send_burst_traffic method")
        return NotImplementedError('Moongen Burst traffic not implemented')

    def send_cont_traffic(self, traffic=None, duration=20):
        """Send a continuous flow of traffic.r

        Send packets at ``framerate``, using ``traffic`` configuration,
        until timeout ``time`` occurs.

        :param traffic: Detailed "traffic" spec, i.e. IP address, VLAN tags
        :param duration: Time to wait to receive packets (secs)
        :returns: dictionary of strings with following data:
            - Tx Throughput (fps),
            - Rx Throughput (fps),
            - Tx Throughput (mbps),
            - Rx Throughput (mbps),
            - Tx Throughput (% linerate),
            - Rx Throughput (% linerate),
            - Min Latency (ns),
            - Max Latency (ns),
            - Avg Latency (ns)
        """
        self._logger.info("In moongen send_cont_traffic method")
        return NotImplementedError('Moongen continuous traffic not implemented')

    def start_cont_traffic(self, traffic=None, duration=20):
        #
        # Non-blocking version of 'send_cont_traffic'.
        #
        # Start transmission and immediately return. Do not wait for
        # results.
        # :param traffic: Detailed "traffic" spec, i.e. IP address, VLAN tags
        # :param duration: Time to wait to receive packets (secs)

        self._logger.info("In moongen start_cont_traffic method")
        return NotImplementedError('Moongen continuous traffic not implemented')

    def stop_cont_traffic(self):
        # Stop continuous transmission and return results.
        self._logger.info("In moongen stop_cont_traffic method")



    @staticmethod
    def run_moongen_and_collect_results(test_run=1):
        """
        Execute MoonGen and transform results into VSPERF format
        """
        moongen_host_ip_addr = settings.getValue('TRAFFICGEN_MOONGEN_HOST_IP_ADDR')
        moongen_base_dir = settings.getValue('TRAFFICGEN_MOONGEN_BASE_DIR')
        moongen_user = settings.getValue('TRAFFICGEN_MOONGEN_USER')
        connect_moongen = "ssh " + moongen_user + "@" + moongen_host_ip_addr
        cmd_moongen = " 'cd " + moongen_base_dir + "; ./build/MoonGen examples/opnfv-vsperf.lua | tee moongen_log.txt'"
        cmd_start_moongen = connect_moongen + cmd_moongen
        start_moongen = subprocess.Popen(cmd_start_moongen, shell=True, stderr=subprocess.PIPE)
        output, error = start_moongen.communicate()

        if start_moongen.returncode:
            print(error)
            print(output)
            raise RuntimeError('MOONGEN: Error starting MoonGen program at %s within %s' \
                    % (moongen_host_ip_addr, moongen_base_dir))

        cmd_moongen = "mkdir -p /tmp/moongen/" + str(test_run)

        moongen_create_log_dir = subprocess.Popen(cmd_moongen, shell=True, stderr=subprocess.PIPE)
        output, error = moongen_create_log_dir.communicate()
        print(output)

        if moongen_create_log_dir.returncode:
            print(error)
            print(output)
            raise RuntimeError('MOONGEN: Error obtaining MoonGen log from %s within %s' \
                    % (moongen_host_ip_addr, moongen_base_dir))


        cmd_moongen = " scp " + moongen_user + "@" + moongen_host_ip_addr + ":" + \
                moongen_base_dir + "/moongen_log.txt /tmp/moongen/" + str(test_run) + "/moongen-run.log"

        copy_moongen_log = subprocess.Popen(cmd_moongen, shell=True, stderr=subprocess.PIPE)
        output, error = copy_moongen_log.communicate()

        if copy_moongen_log.returncode:
            print(error)
            print(output)
            raise RuntimeError('MOONGEN: Error obtaining MoonGen log from %s within %s' \
                    % (moongen_host_ip_addr, moongen_base_dir))

        log_file = "/tmp/moongen/" + str(test_run) + "/moongen-run.log"

        with open(log_file, 'r') as logfile_handle:
            mytext = logfile_handle.read()


            #
            # match.group(1) = Tx frames
            # match.group(2) = Rx frames
            # match.group(3) = Frame loss (count)
            # match.group(4) = Frame loss (percentage)
            # match.group(5) = Tx Mpps
            # match.group(6) = Rx Mpps
            #
            stat_pattern = re.compile(
                r'\[REPORT\]\s+total\:\s+'         # the line we are looking for
                r'Tx\s+frames\:\s+(\d+)\s+'        # tx frames
                r'Rx\s+Frames\:\s+(\d+)\s+'        # rx frames
                r'frame\s+loss\:\s+(\d+)\,'        # frames lost
                r'\s+(\d+\.\d+|\d+)%\s+'           # frame loss percentage
                r'Tx\s+Mpps\:\s+(\d+.\d+|\d+)\s+'  # tx bit rate
                r'Rx\s+Mpps\:\s+(\d+\.\d+|\d+)',   # rx bit rate
                re.IGNORECASE)

            match = stat_pattern.search(mytext)

            build_moongen_results = OrderedDict()
            build_moongen_results[MoonGenResultsConstants.TX_FRAMES] = float(match.group(1))
            build_moongen_results[MoonGenResultsConstants.RX_FRAMES] = float(match.group(2))
            build_moongen_results[MoonGenResultsConstants.FRAME_LOSS_COUNT] = float(match.group(3))
            build_moongen_results[MoonGenResultsConstants.FRAME_LOSS_PERCENT] = float(match.group(4))
            build_moongen_results[MoonGenResultsConstants.TX_MPPS] = float(match.group(5))
            build_moongen_results[MoonGenResultsConstants.RX_MPPS] = float(match.group(6))

            #
            # parameters_match.group(1) = Start rate
            # parameters_match.group(2) = Number of flows
            # parameters_match.group(3) = Frame size
            #
            parameters_pattern = re.compile(
                r'\[PARAMETERS\]\s+'                # find PARAMETERS line
                r'startRate\:\s+(\d+\.\d+|\d+)\s+'  # Starting TX rate
                r'nrFlows\:\s+(\d+)\s+'             # No. of flows
                r'frameSize\:\s+(\d+)',             # Frame size
                flags=re.IGNORECASE)

            parameters_match = parameters_pattern.search(mytext)

            build_moongen_results[MoonGenResultsConstants.START_RATE] = (
                float(parameters_match.group(1)))

            build_moongen_results[MoonGenResultsConstants.NUMBER_OF_STREAMS] = (
                float(parameters_match.group(2)))

            build_moongen_results[MoonGenResultsConstants.FRAME_SIZE] = (
                float(parameters_match.group(3)))

        # Assume for now 10G link speed
        max_theoretical_mfps = (
            (10000000000 / 8) / (build_moongen_results[MoonGenResultsConstants.FRAME_SIZE] + 20))

        moongen_results = OrderedDict()

        moongen_results[ResultsConstants.THROUGHPUT_RX_FPS] = (
            build_moongen_results[MoonGenResultsConstants.RX_MPPS] * 1000000)

        moongen_results[ResultsConstants.THROUGHPUT_RX_MBPS] = (
            build_moongen_results[MoonGenResultsConstants.RX_MPPS] *
            (build_moongen_results[MoonGenResultsConstants.FRAME_SIZE] + 20) * 8)

        moongen_results[ResultsConstants.THROUGHPUT_RX_PERCENT] = (
            build_moongen_results[MoonGenResultsConstants.RX_MPPS] *
            1000000 / max_theoretical_mfps * 100)

        moongen_results[ResultsConstants.TX_RATE_FPS] = (
            build_moongen_results[MoonGenResultsConstants.TX_MPPS] * 1000000)

        moongen_results[ResultsConstants.TX_RATE_MBPS] = (
            build_moongen_results[MoonGenResultsConstants.TX_MPPS] *
            (build_moongen_results[MoonGenResultsConstants.FRAME_SIZE] + 20) * 8)

        moongen_results[ResultsConstants.TX_RATE_PERCENT] = (
            build_moongen_results[MoonGenResultsConstants.TX_MPPS] *
            1000000 / max_theoretical_mfps * 100)

        moongen_results[ResultsConstants.B2B_TX_COUNT] = (
            build_moongen_results[MoonGenResultsConstants.TX_FRAMES])

        moongen_results[ResultsConstants.B2B_FRAMES] = (
            build_moongen_results[MoonGenResultsConstants.RX_FRAMES])

        moongen_results[ResultsConstants.B2B_FRAME_LOSS_FRAMES] = (
            build_moongen_results[MoonGenResultsConstants.FRAME_LOSS_COUNT])

        moongen_results[ResultsConstants.B2B_FRAME_LOSS_PERCENT] = (
            build_moongen_results[MoonGenResultsConstants.FRAME_LOSS_PERCENT])

        return moongen_results



    def send_rfc2544_throughput(self, traffic=None, duration=20,
                                lossrate=0.0, trials=1):
        #
        # Send traffic per RFC2544 throughput test specifications.
        #
        # Send packets at a variable rate, using ``traffic``
        # configuration, until minimum rate at which no packet loss is
        # detected is found.
        #
        # :param traffic: Detailed "traffic" spec, see design docs for details
        # :param trials: Number of trials to execute
        # :param duration: Per iteration duration
        # :param lossrate: Acceptable lossrate percentage
        # :returns: dictionary of strings with following data:
        #     - Tx Throughput (fps),
        #     - Rx Throughput (fps),
        #     - Tx Throughput (mbps),
        #     - Rx Throughput (mbps),
        #     - Tx Throughput (% linerate),
        #     - Rx Throughput (% linerate),
        #     - Min Latency (ns),
        #     - Max Latency (ns),
        #     - Avg Latency (ns)
        #
        self._logger.info("In moongen send_rfc2544_throughput method")
        self._params.clear()
        self._params['traffic'] = self.traffic_defaults.copy()

        if traffic:
            self._params['traffic'] = merge_spec(self._params['traffic'],
                                                 traffic)
        Moongen._create_moongen_cfg_file(traffic, duration=duration, acceptable_loss_pct=lossrate)


        total_throughput_rx_fps = 0
        total_throughput_rx_mbps = 0
        total_throughput_rx_pct = 0
        total_throughput_tx_fps = 0
        total_throughput_tx_mbps = 0
        total_throughput_tx_pct = 0
        total_min_latency_ns = 0
        total_max_latency_ns = 0
        total_avg_latency_ns = 0


        for test_run in range(1, trials+1):
            collected_results = Moongen.run_moongen_and_collect_results(test_run=test_run)

            total_throughput_rx_fps += float(collected_results[ResultsConstants.THROUGHPUT_RX_FPS])
            total_throughput_rx_mbps += float(collected_results[ResultsConstants.THROUGHPUT_RX_MBPS])
            total_throughput_rx_pct += float(collected_results[ResultsConstants.THROUGHPUT_RX_PERCENT])
            total_throughput_tx_fps += float(collected_results[ResultsConstants.TX_RATE_FPS])
            total_throughput_tx_mbps += float(collected_results[ResultsConstants.TX_RATE_MBPS])
            total_throughput_tx_pct += float(collected_results[ResultsConstants.TX_RATE_PERCENT])
            total_min_latency_ns = 0
            total_max_latency_ns = 0
            total_avg_latency_ns = 0


        results = OrderedDict()
        results[ResultsConstants.THROUGHPUT_RX_FPS] = '{:,.6f}'.format(total_throughput_rx_fps / trials)
        results[ResultsConstants.THROUGHPUT_RX_MBPS] = '{:,.3f}'.format(total_throughput_rx_mbps / trials)
        results[ResultsConstants.THROUGHPUT_RX_PERCENT] = '{:,.3f}'.format(total_throughput_rx_pct / trials)
        results[ResultsConstants.TX_RATE_FPS] = '{:,.6f}'.format(total_throughput_tx_fps / trials)
        results[ResultsConstants.TX_RATE_MBPS] = '{:,.3f}'.format(total_throughput_tx_mbps / trials)
        results[ResultsConstants.TX_RATE_PERCENT] = '{:,.3f}'.format(total_throughput_tx_pct / trials)
        results[ResultsConstants.MIN_LATENCY_NS] = '{:,.3f}'.format(total_min_latency_ns / trials)
        results[ResultsConstants.MAX_LATENCY_NS] = '{:,.3f}'.format(total_max_latency_ns / trials)
        results[ResultsConstants.AVG_LATENCY_NS] = '{:,.3f}'.format(total_avg_latency_ns / trials)
        return results

    def start_rfc2544_throughput(self, traffic=None, trials=3, duration=20,
                                 lossrate=0.0):
        """Non-blocking version of 'send_rfc2544_throughput'.

        Start transmission and immediately return. Do not wait for
        results.
        """
        self._logger.info("MOONGEN: In moongen start_rfc2544_throughput method")


    def wait_rfc2544_throughput(self):
        """Wait for and return results of RFC2544 test.
        """
        self._logger.info('In moongen wait_rfc2544_throughput')
        results = OrderedDict()
        results[ResultsConstants.THROUGHPUT_RX_FPS] = 0
        results[ResultsConstants.THROUGHPUT_RX_MBPS] = 0
        results[ResultsConstants.THROUGHPUT_RX_PERCENT] = 0
        results[ResultsConstants.TX_RATE_FPS] = 0
        results[ResultsConstants.TX_RATE_MBPS] = 0
        results[ResultsConstants.TX_RATE_PERCENT] = 0
        results[ResultsConstants.MIN_LATENCY_NS] = 0
        results[ResultsConstants.MAX_LATENCY_NS] = 0
        results[ResultsConstants.AVG_LATENCY_NS] = 0
        return results




    def send_rfc2544_back2back(self, traffic=None, duration=60,
                               lossrate=0.0, trials=1):
        """Send traffic per RFC2544 back2back test specifications.

        Send packets at a fixed rate, using ``traffic``
        configuration, for duration seconds.

        :param traffic: Detailed "traffic" spec, see design docs for details
        :param trials: Number of trials to execute
        :param duration: Per iteration duration
        :param lossrate: Acceptable loss percentage

        :returns: Named tuple of Rx Throughput (fps), Rx Throughput (mbps),
            Tx Rate (% linerate), Rx Rate (% linerate), Tx Count (frames),
            Back to Back Count (frames), Frame Loss (frames), Frame Loss (%)
        :rtype: :class:`Back2BackResult`
        moongen_host_ip_addr = settings.getValue('TRAFFICGEN_MOONGEN_HOST_IP_ADDR')
        moongen_base_dir = settings.getValue('TRAFFICGEN_MOONGEN_BASE_DIR')
        moongen_user = settings.getValue('TRAFFICGEN_MOONGEN_USER')
        """
        self._params.clear()
        self._params['traffic'] = self.traffic_defaults.copy()

        if traffic:
            self._params['traffic'] = merge_spec(self._params['traffic'],
                                                 traffic)

        Moongen._create_moongen_cfg_file(traffic, duration=duration, acceptable_loss_pct=lossrate)

        total_throughput_rx_fps = 0
        # total_throughput_rx_mbps = 0
        total_throughput_rx_pct = 0
        total_throughput_tx_fps = 0
        # total_throughput_tx_mbps = 0
        total_throughput_tx_pct = 0
        total_aggregate_tx_frames = 0
        total_aggregate_rx_frames = 0
        total_frame_loss_count = 0
        total_frame_loss_pct = 0


        for test_run in range(1, trials+1):
            collected_results = Moongen.run_moongen_and_collect_results(test_run=test_run)

            total_throughput_rx_fps += float(collected_results[ResultsConstants.THROUGHPUT_RX_FPS])
            # total_throughput_rx_mbps += float(collected_results[ResultsConstants.THROUGHPUT_RX_MBPS])
            total_throughput_rx_pct += float(collected_results[ResultsConstants.THROUGHPUT_RX_PERCENT])
            total_throughput_tx_fps += float(collected_results[ResultsConstants.TX_RATE_FPS])
            # total_throughput_tx_mbps += float(collected_results[ResultsConstants.TX_RATE_MBPS])
            total_throughput_tx_pct += float(collected_results[ResultsConstants.TX_RATE_PERCENT])
            total_aggregate_tx_frames += int(collected_results[ResultsConstants.B2B_TX_COUNT])
            total_aggregate_rx_frames += int(collected_results[ResultsConstants.B2B_FRAMES])
            total_frame_loss_count += int(collected_results[ResultsConstants.B2B_FRAME_LOSS_FRAMES])
            total_frame_loss_pct += int(collected_results[ResultsConstants.B2B_FRAME_LOSS_PERCENT])


        avg_throughput_rx_fps = total_throughput_rx_fps / trials
        # avg_throughput_rx_mbps = total_throughput_rx_mbps / trials
        avg_throughput_rx_pct = total_throughput_rx_pct / trials
        avg_throughput_tx_fps = total_throughput_tx_fps / trials
        # avg_throughput_tx_mbps = total_throughput_tx_mbps / trials
        avg_throughput_tx_pct = total_throughput_tx_pct / trials
        avg_aggregate_tx_frames = total_aggregate_tx_frames / trials
        avg_aggregate_rx_frames = total_aggregate_rx_frames / trials
        avg_total_frame_loss_count = total_frame_loss_count / trials
        avg_total_frame_loss_pct = total_frame_loss_pct / trials

        results = OrderedDict()

        results[ResultsConstants.B2B_RX_FPS] = avg_throughput_rx_fps
        results[ResultsConstants.B2B_TX_FPS] = avg_throughput_tx_fps
        results[ResultsConstants.B2B_RX_PERCENT] = avg_throughput_rx_pct
        results[ResultsConstants.B2B_TX_PERCENT] = avg_throughput_tx_pct
        results[ResultsConstants.B2B_TX_COUNT] = avg_aggregate_tx_frames
        results[ResultsConstants.B2B_FRAMES] = avg_aggregate_rx_frames
        results[ResultsConstants.B2B_FRAME_LOSS_FRAMES] = avg_total_frame_loss_count
        results[ResultsConstants.B2B_FRAME_LOSS_PERCENT] = avg_total_frame_loss_pct
        results[ResultsConstants.SCAL_STREAM_COUNT] = 0
        results[ResultsConstants.SCAL_STREAM_TYPE] = 0
        results[ResultsConstants.SCAL_PRE_INSTALLED_FLOWS] = 0
        return results


        #return NotImplementedError('Moongen back2back traffic not implemented')

    def start_rfc2544_back2back(self, traffic=None, trials=1, duration=20,
                                lossrate=0.0):
        #
        # Non-blocking version of 'send_rfc2544_back2back'.
        #
        # Start transmission and immediately return. Do not wait for results.
        #
        self._logger.info("In moongen start_rfc2544_back2back method")
        return NotImplementedError('Moongen back2back traffic not implemented')

    def wait_rfc2544_back2back(self):
        self._logger.info("In moongen wait_rfc2544_back2back method")
        #
        # Wait and set results of RFC2544 test.
        #


if __name__ == "__main__":
    pass
