class Controller(object):
    def __init__(self):
        self.Kp = 15.000000
        self.h = 0.100000
        self.Ki = 0.010000
        self.I = 0
        self.Kd = 3.000000
        self.em1 = 0

    def __call__(self, r, x):
        e = r - x
        u = self.Kp * e + self.I + self.Kd * (e - self.em1) / self.h
        if u >= 10.000000:
            u = 10.000000
        elif u <= -10.000000:
            u = -10.000000
        else:
            self.I = self.I + self.Ki * e * self.h
        self.em1 = e
        return u

    def __str__(self):
        return "PIDAW controller object"