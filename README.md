# Project Title

Automated-Installer




## Getting Started

These instructions will get you a copy of the project up and running on your local machine.





### Installing

Change to your user's home directory
so you will clone the project there later (you can choose any other loacation) 

```
cd ~
```

Clone the project:

```
git clone https://github.com/BigRush/Automated-Installer.git
```



## Running the script

Change to the project's directory:

```
cd Automated-Installer
```

### To Run the script you'll need to run it once as **root** and once as **non-root**:


To run the post-install part (which is **option 1** on the menu under Main.sh) you'll must run the script as **root**

```
sudo bash Main.sh
```


To run the aurman part (which is **option 2** on the menu under Main.sh) you'll must run the script as **non-root**

```
bash Main.sh
```
## Logs
There are log files under "log" folder in the directory of the project: 
 * error.log - All **stderr** from the commands of the script will be there
 
 * output.log - All **stdout** from the commands of the script will be there




## Built With

* [Atom](https://atom.io/) - The text editor used


## Authors

* **Tom H.** - [BigRush](https://github.com/bigrush)


## License

This project is licensed under the GPLv3 License - see the [LICENSE](https://github.com/chn555/timestamp/blob/master/LICENSE) file for details


## Acknowledgments

Thanks to [silent-mobius](https://github.com/silent-mobius) for giving the idea and mentoring me through the process.