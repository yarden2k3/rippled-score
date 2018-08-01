from tkinter import *
import os
import tkinter.messagebox as box
import subprocess
from puzzle import GameGrid


def dialog1():
    game_grid = GameGrid(window)
    game_grid.tkraise()
    return
    username=entry1.get()
    password = entry2.get()
    #check if valid
    r = subprocess.run(['rp_user_validator', username , password])
    print (r.returncode)
    if (r.returncode == 0):
        box.showinfo('info','Correct Login')
    else:
        box.showinfo('info','Username or Password incorrect')

def dialog2():
    #subprocess.call(['create_player'])
    x = subprocess.check_output(['rp_create_player'])   
    box.showinfo('info' , x)


window = Tk()
window.title('Countries Generation')
frame = Frame(window)

Label1 = Label(window,text = 'Username:')
Label1.pack(padx=15,pady= 5)

entry1 = Entry(window,bd =5)
entry1.pack(padx=15, pady=5)


Label2 = Label(window,text = 'Password: ')
Label2.pack(padx = 15,pady=6)

entry2 = Entry(window, bd=5)
entry2.pack(padx = 15,pady=7)

btn = Button(frame, text = 'Check Login',command = dialog1)

btn2 = Button(frame, text = 'Create Player',command = dialog2)

btn.pack(side = RIGHT , padx =5)
btn2.pack(side = LEFT , padx=2)
frame.pack(padx=100,pady = 19)
window.mainloop()
