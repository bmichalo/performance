import logging
import subprocess
args = ['ls','-ltr']
process_ls = subprocess.Popen(args, shell=False)
output, error = process_ls.communicate()

#output, error = process_ls.communicate()
#print(output)
