## 1st step:  increase/resize disque  from  GUI console
## 2nd step : Extend physical drive partition
### check free space : 
```python
sudo fdisk -l
```
### Extend physical drive partition 
```python 
growpart /dev/sda 3
 ```  
### See  phisical drive  
```python 
pvdisplay   
```  
### Instruct LVM that disk size has changed
```python
sudo pvresize /dev/sda3
```    
(Instruct LVM that disk size has changed)
```python
pvdisplay
```    
(  check physical drive if has changed  ) 



## 3rd step:  Extend  Logical  volume [/U]
### View starting LV
```python
lvdisplay
```
### Resize LV
```python
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
```   
### View changed LV
```python
 lvdisplay 
```


## 4th  step  :   Resize Filesystem
```python
 resize2fs /dev/ubuntu-vg/ubuntu-lv
```
### Confirm results
```python
 fdisk -l
``` 