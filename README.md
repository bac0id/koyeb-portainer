# Koyeb-Portainer

A solution to deploy [Portainer CE](https://github.com/portainer/portainer) in [Koyeb](https://www.koyeb.com/) Docker Container. 

## Overview

On Koyeb, a free plan user can deploy 1 container. In our solution, we deploy a container of ubuntu, and install docker on it. 

At the entrypoint of container, we start docker service with command `dockerd` on another process (thread). Then larger swap is set. Finally, we run a container of portainer-ce and port forward `9000` of portainer-ce container, to `9000` of ubuntu container. 

On Koyeb dashboard, we expose port `9000` of ubuntu to enable public access. 

![Structure](koyeb-portainer-structure.svg)

## Deploy

1.  Go to Koyeb dashborad. 

2.  Create a service with this GitHub repository. 

    ```
    https://github.com/bac0id/koyeb-portainer.git
    ```

3.  Choose instance and regions. 

4.  Change deploy settings. 
    
    * Switch builder to Dockerfile, and set privileged to true.

    * Set exposed port on `9000`.

5.  Wait for building and deploying. 

6.  Go to displayed public URL. Set admin password for Portainer in time. 

7.  Enjoy.

## Limitation

Ubuntu, Docker and Portainer CE consume about 400 MB RAM according to my Koyeb dashboard. 

## Disclaimer

This deployment may violate [Koyeb's Terms of Service](https://www.koyeb.com/docs/legal/terms). The copyright holder of this repository is not responsible for your Koyeb account. 

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## License

MIT License

Copyright (c) 2025 BAC
