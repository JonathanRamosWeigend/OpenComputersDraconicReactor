# OpenComputersDraconicReactor
Control Program for Open Computers 1.7 controlling the Draconic Reactor in Minecraft 1.12.2

The program is written with Lua. It runs on any OS on Open Computers inside Minecraft. To download the program make sure your computer has
integrated the Internet Card inside your computer. Use the following command for download:
wget https://raw.githubusercontent.com/JonathanRamosWeigend/OpenComputersDraconicReactor/main/reactor-control.lua

The program controls two Flux-Gates. Gate one controls the energy output of the reactor. The program tries to increase the value until the temperature threshhold is reached or the given percentual value of the maximum energy (50%) is reached.
The second flux controls the energy input. The program controls the energy input (field strength) to stay on a constant value (50%)
The control frequency is one cycle per second. By clicking at the sceen of your computer, you can speed up the progress, but make sure your reactor does not get instable!!! :-)
The program will initiate a shutdown of the reactor if the fuel depletion value reaches 90%.
The program exits on any key.

Draconic Reator with Open Computers
![2023-01-02_19 03 50](https://user-images.githubusercontent.com/25133150/210278073-6dd45b48-a888-4dc4-9a76-66cf0ed50377.png)

Screenshot of our control UI
![2023-01-02_19 03 54](https://user-images.githubusercontent.com/25133150/210278081-9fb6bd6e-e901-41df-9935-9651abdd75c6.png)

Screenshot of the Draconic Reactor UI
![2023-01-02_19 05 35](https://user-images.githubusercontent.com/25133150/210278086-0f96605b-fc33-44c7-a995-096aa5fcf608.png)

Lua Developing with Visual Studio Code
![reactor-control lua - DraconicReactor - Visual Studio Code 02 01 2023 18_05_03](https://user-images.githubusercontent.com/25133150/210278088-8a23553f-f780-4037-862f-3ec755f44672.png)
