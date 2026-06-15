FROM docker.io/debian:latest
#Args: Required NODE_PASSWORD(setting to "null" will not set a password),
#		Enable ( EMACS, VIM, SSH )
# Ports: 22/ssh
RUN echo "\e[0;34mArgs:\e[0m\n"\
		 " \e[0;31mRequired\e[0m\n"\
		 "   \e[4;32mNODE_PASSWORD\e[0m\n"\
		 " \e[1;35mOptions\e[0m\n"\
		 "  \e[4;34mEMACS\e[0m\n"\
		 "  \e[4;34mVIM\e[0m\n"\
		 "  \e[4;34mSSH\e[0m"


RUN apt-get update && apt-get install -y fish sudo curl unzip git

RUN useradd -mG sudo node

RUN chsh -s /usr/bin/fish root && chsh -s /usr/bin/fish node

USER node
WORKDIR /home/node

RUN curl -o- https://fnm.vercel.app/install | bash
RUN fish -c "fnm install 24"
RUN fish -c "corepack enable pnpm"
RUN fish -c 'echo "y" | pnpm | tee'
RUN echo "alias npm pnpm\n" \
		 "alias npx pnpx" | tee -a /home/node/.config/fish/config.fish

USER root


ARG EMACS=0
RUN if [ "${EMACS}" != "0" ]; then echo "\e[0;35minstalling emacs\e[0m"; \
		apt-get install -y emacs; \
	fi

ARG VIM=0
RUN if [ "${VIM}" != "0" ]; then echo "\e[0;32minstalling vim\e[0m"; \
		apt-get install -y vim; \
	fi

ARG SSH=0
RUN if [ "${SSH}" != "0" ]; then echo "\e[0;36minstalling openssh-server\e[0m"; \
		apt-get install -y openssh-server; \
	fi

RUN if [ "${SSH}" != "0" ]; then \
	echo "#!/bin/sh\n"		\
		 "/usr/sbin/sshd\n"	\
		 "exec su node\n" | tee /entry.sh; \
	else \
	echo "#!/bin/sh\n"\
		 "exec su node" | tee /entry.sh; \
	fi

RUN chmod +x /entry.sh

ARG NODE_PASSWORD

RUN if [ ! ${NODE_PASSWORD} ]; then echo "\e[0;31mPassword was not Setted,\n please set NODE_PASSWORD using\n  --build-arg NODE_PASSWORD=<your password>\e[0m"; exit 1; fi 
RUN if [ "${NODE_PASSWORD}" != "null" ]; then echo "\e[0;31mSetting password\e[0m"; echo "node:${NODE_PASSWORD}" | chpasswd; fi

RUN echo "\n\n"; \
	if [ "${EMACS}" != "0" ]; then echo "\e[1;32memacs was installed\e[0m"; else echo "\e[1;31memacs was not installed\e[0m"; fi; \
	if [ "${VIM}" != "0" ]; then echo "\e[1;32mvim was installed\e[0m"; else echo "\e[1;31mvim was not instaled\e[0m"; fi;        \
	if [ "${SSH}" != "0" ]; then echo "\e[1;32msshd was installed\e[0m"; else echo "\e[1;31msshd was not installed\e[0m"; fi;     \
	echo "";\
	if [ "${NODE_PASSWORD}" = "null" ]; then echo "\e[1;33mno user password setted\e[0m"; else echo "\e[1;32muser password setted\e[0m"; fi; \
	echo "\n\n"
ENTRYPOINT ["/entry.sh"]
