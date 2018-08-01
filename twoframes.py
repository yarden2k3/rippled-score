import tkinter as tk                # python 3
from tkinter import font  as tkfont # python 3
import subprocess
import tkinter.messagebox as box


#import Tkinter as tk     # python 2
#import tkFont as tkfont  # python 2

class SampleApp(tk.Tk):

    def __init__(self, *args, **kwargs):
        tk.Tk.__init__(self, *args, **kwargs)

        self.title_font = tkfont.Font(family='Helvetica', size=18, weight="bold", slant="italic")

        # the container is where we'll stack a bunch of frames
        # on top of each other, then the one we want visible
        # will be raised above the others
        container = tk.Frame(self)
        container.pack(side="top", fill="both", expand=True)
        container.grid_rowconfigure(0, weight=1)
        container.grid_columnconfigure(0, weight=1)

        self.frames = {}
        for F in (StartPage, PageOne, PageTwo):
            page_name = F.__name__
            frame = F(parent=container, controller=self)
            self.frames[page_name] = frame

            # put all of the pages in the same location;
            # the one on the top of the stacking order
            # will be the one that is visible.
            frame.grid(row=0, column=0, sticky="nsew")

        self.show_frame("PageTwo")

    def show_frame(self, page_name):
        '''Show a frame for the given page name'''
        frame = self.frames[page_name]
        frame.tkraise()


class StartPage(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        label = tk.Label(self, text="This is the start page", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)

        button1 = tk.Button(self, text="Go to Page One",
                            command=lambda: controller.show_frame("PageOne"))
        button2 = tk.Button(self, text="Go to Page Two",
                            command=lambda: controller.show_frame("PageTwo"))
        button1.pack()
        button2.pack()


class PageOne(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        label = tk.Label(self, text="This is page 1", font=controller.title_font)
        label.pack(side="top", fill="x", pady=10)
        button = tk.Button(self, text="Go to the start page",
                           command=lambda: controller.show_frame("StartPage"))
        button.pack()


class PageTwo(tk.Frame):

    def __init__(self, parent, controller):
        tk.Frame.__init__(self, parent)
        self.controller = controller
        #label = tk.Label(self, text="This is page 2", font=controller.title_font)
        #label.pack(side="top", fill="x", pady=10)
       # button = tk.Button(self, text="Go to the start page",
        #                   command=lambda: controller.show_frame("StartPage"))
        #button.pack()

        #window = tk.Tk()
        #window.title('Countries Generation')
        #frame = tk.Frame(window)

        Label1 = tk.Label(self, text = 'Username:')
        Label1.pack(padx=15,pady= 5)

        self.entry1 = tk.Entry(self,bd =5)
        self.entry1.pack(padx=15, pady=5)


        Label2 = tk.Label(self,text = 'Password: ')
        Label2.pack(padx = 15,pady=6)

        self.entry2 = tk.Entry(self, bd=5)
        self.entry2.pack(padx = 15,pady=7)
        #button = tk.Button(self, text="Go to the start page",
         #                  command=lambda: controller.show_frame("StartPage"))
        btn = tk.Button(self, text = 'Check Login',                                                                                                                                                                                         command = self.dialog1)

        btn2 = tk.Button(self, text = 'Create Player',command = self.dialog2)

        btn.pack(side = "right" , padx =5)
        btn2.pack(side = "left" , padx=2)
        #window.pack(padx=100,pady = 19)
        #window.mainloop()

    def dialog1(self):
        username = self.entry1.get()
        password = self.entry2.get()
        #check if valid
        r = subprocess.run(['rp_user_validator', username , password])
        print (r.returncode)
        if True or r.returncode == 0:
            box.showinfo('info','Correct Login')
            self.controller.username = username
            self.controller.password = password
            self.controller.show_frame("PageOne")
            
        else:
            box.showinfo('info','Username or Password incorrect')

    def dialog2(self):
        #subprocess.call(['create_player'])
        x = subprocess.check_output(['rp_create_player'])   
        box.showinfo('info' , x)

if __name__ == "__main__":
    app = SampleApp()
    app.mainloop()