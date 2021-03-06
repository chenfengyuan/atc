#!/usr/bin/env python3
# coding=utf-8
__author__ = 'chenfengyuan'

import tornado.web
import tornado.ioloop
import tornado.iostream
import tornado.tcpserver
import tornado.netutil
import os
import threading
import time


def read_file(filename):
    pr, pw = os.pipe()
    sr = tornado.iostream.PipeIOStream(pr)

    def read():
        f = open(filename)
        sw = tornado.iostream.PipeIOStream(pw)
        while True:
            line = f.readline()
            if line:
                tornado.ioloop.IOLoop.instance().add_callback(
                    lambda sw_, line_: sw_.write(line_.encode('utf-8')), sw, line)
            else:
                time.sleep(0.01)
    t = threading.Thread(target=read)
    t.daemon = True
    t.start()
    return sr


def write_file(filename):
    pr, pw = os.pipe()
    sw = tornado.iostream.PipeIOStream(pw)

    def dummy():
        f = open(filename, 'wb', 0)
        sr = tornado.iostream.PipeIOStream(pr)

        def on_data(data):
            f.write(data)

        def dummy2():
            sr.read_until_close(on_data, on_data)
        tornado.ioloop.IOLoop.instance().add_callback(dummy2)
    t = threading.Thread(target=dummy)
    t.daemon = True
    t.start()
    return sw


class Action(tornado.web.RequestHandler):

    def __init__(self, application, request, **kwargs):
        self.status = None
        self.action_stream = None
        super().__init__(application, request, **kwargs)

    def initialize(self, status, action_stream):
        self.status = status
        self.action_stream = action_stream

    def get(self):
        self.write(self.status)

    def post(self):
        self.action_stream.write(self.request.body)


def main():
    status = {'data': ''}

    sin = read_file('atc_status')

    def on_in_data(data):
        sin.read_until(b'\n\n', on_in_data)
        status['data'] = data.decode('utf-8')
        status['update_time'] = time.time()
    sout = write_file('action')
    #sin.read_until_close(on_in_data, on_in_data)
    sin.read_until(b'\n\n', on_in_data)
    application = tornado.web.Application(
        [[r'.*', Action, dict(status=status, action_stream=sout)]])
    application.listen(14200)
    tornado.ioloop.IOLoop.instance().start()

if __name__ == '__main__':
    main()
