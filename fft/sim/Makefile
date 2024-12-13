help:
	@echo "listfile to generate"
	@echo "vcs to complie"
	@echo "verdi to debug with wave"
	@echo "clean to remove all temporary files"

#----文件列表---
listfile:
	(find ./.. -maxdepth 2 -name "define.v"; find ./.. -maxdepth 2  -name "*.v" ! -name "define.v") > filelist.f

#----VCS编译----
VCS_OPTIONS = -sverilog 						\
			  +v2k 								\
			  -full64 							\
			  -Debug_access+all 				\
			  -LDFLAGS -Wl,--no-as-needed 		\
			  -R								\
			  +vcs+lic+wait						\
			  +lint=all,noTMR,noVCDE,noULCO,noWMIA-L		\
			  -timescale=1ns/1ns 				\
			  -f filelist.f					    \
			  -P /home/zjh/synopsys/verdi/Verdi_O-2018.09-SP2/share/PLI/VCS/linux64/novas.tab  \
			  	 /home/zjh/synopsys/verdi/Verdi_O-2018.09-SP2/share/PLI/VCS/linux64/pli.a      

vcs:
	vcs $(VCS_OPTIONS) | tee vcs.log

#----verdi debug----
verdi:
	verdi -f filelist.f  -sverilog -ssf *.fsdb -nologo &

#----清除中间文件----
clean:
	rm -rf csrc *.log *.key *simv* *.vpd *DVE*
	rm -rf verdiLog *.fsdb.* *.fsdb *.bak *.conf *.rc *.f 

