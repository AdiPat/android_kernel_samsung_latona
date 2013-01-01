/*
 *
 *  Copyright (C) 2012, Aditya Patange "Adi_Pat" <adithemagnificent@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Multi-touch Control Interface.
 *
 */

int get_s2wake_status(void);
void slide2wake_pwrtrigger(void);
static struct input_dev *slide2wake_dev;
static struct wake_lock wl_s2w;
