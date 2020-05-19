import sys
import os
import yaml
from git import Repo


## Function to clone Github repo
def clone_repo(git_url):
  repo_dir = os.getcwd()
  try:
    ## Removing existing workspace
    print("[CICD INFO] Removing old workspace, if exist")
    if os.path.exists(repo_dir + "/workingDir"):
      os.system("rm -rf workingDir")
  except:
    print("[CICD ERROR] Error found while cleaning up working directory")
  try:
    ## Cloning github project to workingDir
    print("[CICD INFO] Cloning Repo to /workingDir")
    Repo.clone_from(git_url, repo_dir + "/workingDir")
  except:
    print("[CICD INFO] Error found while cloning repo")
    sys.exit();

    
## CICD Job Starts from here =======================

## Validating command line arguments, expecting 3 arguments (scriptname, stage, githuburl)
if len(sys.argv)<3:
  print ("Usage details: pipeline.py build git_url")
else:
  clone_repo(sys.argv[2])   ## function to clone repo
  print("[CICD INFO] Parsing pipeline.yaml")
  currentPath = os.getcwd()
  stage_flag=0
  task_flag=0
  ## Validating pipeline.yaml file
  if os.path.exists(currentPath + "/workingDir/pipeline.yml"):
     pipeline_fname = open("workingDir/pipeline.yml")
     pipelinedata = yaml.load(pipeline_fname, Loader=yaml.FullLoader)
     if pipelinedata["branch"]:
	print("[CICD INFO] Check out branch: "+ pipelinedata["branch"])
	#Repo.git.checkout(pipelinedata["branch"])
        print("Getting Pipeline stages")
        pipeline_stg=pipelinedata["pipelines"]
	pipeline_tasks=pipelinedata["tasks"]
        for stage in pipeline_stg:
	  for key, value in stage.items():
	     if key == sys.argv[1]:
		print(value)
		stage_flag=1
		print("[CICD INFO] Running pipeline for -" + key)
		print("[CICD INFO] Fetching tasks information")
		for sub_stage in value:
		   for task in pipeline_tasks:
		      for k, v in task.items():
			 if k == sub_stage:
 			    task_flag=1
			    print("[CICD INFO] Executing stage - " + sub_stage)
			    for task_k, sub_task in v.items():
				command="cd workingDir; " + sub_task
				os.system(command)
	if stage_flag == 0:
	   print("[CICD ERROR] Stage not found in the pipeline")
           sys.exit();
	if task_flag == 0:
	   print("[CICD ERROR] Task not found in the pipeline")
           sys.exit();
     else:
        print("[CICD ERROR] Branch not found in the pipeline")
        sys.exit();
  else:
     sys.exit();
