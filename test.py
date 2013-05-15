import sys


def loop(r, w):
    while True:
        line = r.readline()
        if not line:
            break

        if line.strip() == 'quit':
            w.write('quitting (from python)\n')
            break

        # echo
        w.write(line)


if __name__ == '__main__':
    loop(sys.stdin, sys.stdout)
