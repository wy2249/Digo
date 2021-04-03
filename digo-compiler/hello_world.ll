; ModuleID = 'Digo'
source_filename = "Digo"

@str = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@str.1 = private unnamed_addr constant [12 x i8] c"Hello Word!\00"

declare i32 @printInt(i32, ...)

declare i32 @printFloat(double, ...)

declare i32 @printString(i8*, ...)

define void @main() {
entry:
  %printInt = call i32 (i32, ...) @printInt(i32 3)
  %printFloat = call i32 (double, ...) @printFloat(double 4.000000e+00)
  %printString = call i32 (i8*, ...) @printString(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @str.1, i32 0, i32 0))
  ret void
}
