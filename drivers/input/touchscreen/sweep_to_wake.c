/*
 *  Copyright (C) 2012, Aditya Patange "Adi_Pat" <adithemagnificent@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Sweep to Wake Interface. 
 *
 */

#include <linux/kernel.h>
#include <linux/kobject.h>
#include <linux/init.h>
#include <linux/module.h>
#include <linux/sysfs.h>
#include <linux/string.h>
#include <linux/wakelock.h>
#include <linux/delay.h>
#include <linux/input.h>
#include <linux/input/s2wake.h>

#define DRIVER_NAME           "Sweep2Wake"
#define SWEEP2WAKE_VERSION        1

/* Resources */ 

int s2wake_status = 0;


#define X_RES       480
#define Y_RES       800

void slide2wake_setdev(struct input_dev *input_device)
{
	slide2wake_dev = input_device;
	input_set_capability(slide2wake_dev, EV_KEY, KEY_POWER);
}

static void slide2wake_presspwr(struct work_struct *slide2wake_presspwr_work)
{
	input_report_key(slide2wake_dev,KEY_POWER, 0);
	printk(KERN_ERR "[TSP] %s\n", __func__);
 	input_report_key(slide2wake_dev,KEY_POWER,1);
  	// input_event(slide2wake_dev, EV_SYN, 0, 0);
 	msleep(100);
 	// input_event(slide2wake_dev, EV_KEY, KEY_POWER, 0);
 	// input_event(slide2wake_dev, EV_SYN, 0, 0);
 	// msleep(1000);
 	wake_unlock(&wl_s2w);		
}

static DECLARE_WORK(slide2wake_presspwr_work, slide2wake_presspwr);

void slide2wake_pwrtrigger(void)
{
	if(wake_lock_active(&wl_s2w)) return;
	wake_lock_timeout(&wl_s2w, msecs_to_jiffies(2000));
	schedule_work(&slide2wake_presspwr_work);
}

int get_s2wake_status(void)
{
	return s2wake_status;
}


static ssize_t s2wake_status_show(struct kobject *kobj, struct kobj_attribute *attr, 
				char *buf)
{
	return sprintf(buf, "%d\n", s2wake_status);
}

static ssize_t s2wake_status_store(struct kobject *kobj, struct kobj_attribute *attr,
				   const char *buf, size_t count)
{
	int status;
	sscanf(buf, "%d", &status); 
	if(status == 0)
		{
			printk(KERN_DEBUG "[S2WAKE] Sweep to wake: DISABLED\n");
			s2wake_status = 0;
		}
	if(status == 1)
		{
			printk(KERN_DEBUG "[S2WAKE] Sweep to wake: ENABLED\n");
			s2wake_status = 1;
		}
	else
		{
			printk(KERN_DEBUG "[S2WAKE]: INVALID INPUT! \n");
		}
	return count;
}

static ssize_t s2wake_version_show(struct kobject *kobj, struct kobj_attribute *attr,
				char *buf)
{
	return sprintf(buf, "%d\n", SWEEP2WAKE_VERSION);
}

static struct kobj_attribute s2wake_status_attr = __ATTR(s2wake_enable, 0666, s2wake_status_show, s2wake_status_store); 
static struct kobj_attribute s2wake_version     = __ATTR(version, 0666, s2wake_version_show, NULL); 

static struct attribute *s2wake_attributes[] = {
	&s2wake_status_attr.attr,
	&s2wake_version.attr,
	NULL,
};

static struct attribute_group s2wake_grp = {
	.attrs = s2wake_attributes,	
};

static struct kobject *s2wake_kobj;

static int __init s2wake_init(void)
{
	int r;
	printk(KERN_DEBUG "[%s\n]",__func__);
	
	s2wake_kobj = kobject_create_and_add("s2wake", kernel_kobj);

	if(!s2wake_kobj)
		{
		  printk(KERN_DEBUG "[%s] FAILED TO CREATE KOBJECT \n",__func__);	
	          return -ENOMEM;
		}
	r = sysfs_create_group(s2wake_kobj, &s2wake_grp);
	 
	if(r)
		kobject_put(s2wake_kobj);
	
	return r;
}

static void __exit s2wake_exit(void)
{
	kobject_put(s2wake_kobj);
}

module_init(s2wake_init);
module_exit(s2wake_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Aditya Patange");
