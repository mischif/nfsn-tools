Scripts Designed To Make NearlyFreeSpeech.net Easier To Use
===========================================================

The goal of this repository is to collect all the different scripts members of NearlyFreeSpeech.net use to automate common tasks and give them a centralized location where they can be found easily by everyone.

Guidelines For Use
------------------

* Unless instructed otherwise, run the scripts from /home/private. It is the best and most secure location to do so.

Guidelines For Submission
-------------------------

* All non-web-facing scripts (e.g., scripts that update files on the server, make backups and data dumps) must work when run from /home/private. You can have helper scripts elsewhere and you may suggest a different location for your script to be run from, but your script must always function correctly when run from /home/private.

* All scripts must work in the default realm. You can have extra features when run from the beta realms, but your script must be able to complete its primary function when run from the default realm.

* If any part of the script (including helper files) is web facing and could cause appreciable damage if discovered, use some method of authentication (e.g., basic, digest) to protect it.

* All scripts must include a README and LICENSE file.

* If your script requires setup, include it in the README.

* Include authorship information, contact information, etc. at the top of either the README file or the script itself.