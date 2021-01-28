d1=read.csv("../data/student_school_grades/student-mat.csv",header=TRUE) 
d2=read.csv("../data/student_school_grades/student-por.csv",header=TRUE)

d3=merge(d1,d2)
print(nrow(d3)) # 382 students
write.csv(d3, file="../data/student_school_grades/student_merge.csv")
