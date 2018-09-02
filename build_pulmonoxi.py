## Build script for the PulmonOxi application, that versions
#  the configuration files by suffixing the version number to their path.

# The environment is expected to provide variable LN_HOME, the directory of the 
# upstream lambda native repository.

import shutil
import os
import subprocess

## Builds all production versions of PulmonOxi
def build_production():
    #build_version("PulmonOxiVillage","android")
    #build_version("PulmonOxiVillageDemo","android")
    #build_version("PulmonOxiHC","android")
    build_version("PulmonOxiHCDemo","android")
    #build_version("PulmonOxiUpload","win32")
    #build_version("PulmonOxiUploadDemo","win32")

## Builds all testing versions of PulmonOxi
def build_testing():
    build_version("PulmonOxiHCDemo","linux")
    #build_version("PulmonOxiVillageDemo","linux")

## Main entry point
def main():
    build_testing()
    build_production()

def build_version(appname,platform):
    print("Building {:s} for platform {:s}...".format(appname,platform))
    shutil.move("./PulmonOxi","./"+appname)
    os.chdir("./"+appname)
    shutil.copyfile("./local_options.scm","./cache/local_options.scm")
    shutil.copyfile("./templates/"+appname+"/local_options.scm","./local_options.scm")
    with open("./VERSION",'r') as fp:
        lines=fp.readlines()
        assert(len(lines)==1)
        app_version=lines[0].strip()
    with open("./EMBED.in",'r') as fp:
        lines=fp.readlines()
        assert(len(lines)==1)
        embed_files=lines[0].split()
    embed_files_suffixed=list(map(lambda filename: filename.split('.')[0]+"_"+app_version.replace('.','')+"."+filename.split('.')[1],
                                  embed_files))
    for base_embed_file,new_embed_file in zip(embed_files,embed_files_suffixed):
        shutil.copyfile(base_embed_file,new_embed_file)
    new_embed_line=" ".join(embed_files_suffixed)
    with open("./EMBED","w") as fp:
        fp.writelines([new_embed_line])
    ln_upstream_path=os.getenv("LN_HOME")
    orig_wdir=os.getcwd()
    os.chdir(ln_upstream_path)
    subprocess.call(["./configure",appname,platform])
    subprocess.call(["make"])
    os.chdir(orig_wdir)
    shutil.copyfile("./cache/local_options.scm","./local_options.scm")
    os.chdir("..")
    shutil.move("./"+appname,"./PulmonOxi")

if __name__=="__main__":
    main()