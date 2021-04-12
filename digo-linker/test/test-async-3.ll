
; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; DIGO Async Function Metadata BEGIN

; VERSION = 1

; FUNC DECLARE BEGIN
; FUNC_NAME = 'add_int_100'
; FUNC_ANNOT = 'async'
; PARAMETERS = 'int'
; RETURN_TYPE = 'int'
; FUNC DECLARE END

; FUNC DECLARE BEGIN
; FUNC_NAME = 'shift_arg_and_slice'
; FUNC_ANNOT = 'async'
; PARAMETERS = 'int, slice, double, double, string, slice, int'
; RETURN_TYPE = 'slice, double, double, string, slice, int, int'
; FUNC DECLARE END

; DIGO Async Function Metadata END

@.str.format.1 = private unnamed_addr constant [44 x i8] c"Arguments: %d | %l | %f | %f | %s | %l | %d\00", align 1
@.str.format.2 = private unnamed_addr constant [47 x i8] c"Return value: %l | %f | %f | %s | %l | %d | %d\00", align 1
@.str.msg.1 = private unnamed_addr constant [14 x i8] c"Hello, world!\00", align 1
@.str.msg.2 = private unnamed_addr constant [18 x i8] c"Hello, C++ world!\00", align 1
@.str.msg.3 = private unnamed_addr constant [17 x i8] c"Hello, Go world!\00", align 1

@.str.format.0 = private unnamed_addr constant [3 x i8] c"%d\00", align 1

; THIS IS AN ASYNC FUNCTION
define {i64} @add_int_100(i64 %i) #0 {
  %add = add nsw i64 %i, 100

  %aggRet = insertvalue {i64} undef, i64 %add, 0
  ret {i64} %aggRet
}

; THIS IS AN ASYNC FUNCTION
define {i8*, double, double, i8*, i8*, i64, i64} @shift_arg_and_slice(i64 %arg0, i8* %arg1, double %arg2, double %arg3, i8* %arg4, i8* %arg5, i64 %arg6) #0 {
  %format_str_ptr = getelementptr inbounds [44 x i8], [44 x i8]* @.str.format.1, i64 0, i64 0
  %format_str2_ptr = getelementptr inbounds [47 x i8], [47 x i8]* @.str.format.2, i64 0, i64 0

  call void (i8*, ...) @println(i8* %format_str_ptr, i64 %arg0, i8* %arg1, double %arg2, double %arg3, i8* %arg4, i8* %arg5, i64 %arg6)

  %aggRet0 = insertvalue {i8*, double, double, i8*, i8*, i64, i64} undef, i8* %arg1, 0
  %aggRet1 = insertvalue {i8*, double, double, i8*, i8*, i64, i64} %aggRet0, double %arg2, 1
  %aggRet2 = insertvalue {i8*, double, double, i8*, i8*, i64, i64} %aggRet1, double %arg3, 2
  %aggRet3 = insertvalue {i8*, double, double, i8*, i8*, i64, i64} %aggRet2, i8* %arg4, 3
  %aggRet4 = insertvalue {i8*, double, double, i8*, i8*, i64, i64} %aggRet3, i8* %arg5, 4
  %aggRet5 = insertvalue {i8*, double, double, i8*, i8*, i64, i64} %aggRet4, i64 %arg6, 5
  %aggRet6 = insertvalue {i8*, double, double, i8*, i8*, i64, i64} %aggRet5, i64 %arg0, 6

  call void (i8*, ...) @println(i8* %format_str2_ptr, i8* %arg1, double %arg2, double %arg3, i8* %arg4, i8* %arg5, i64 %arg6, i64 %arg0)

  ret {i8*, double, double, i8*, i8*, i64, i64} %aggRet6
}

define void @digo_main() {
entry:

  %msg1_str_ptr = getelementptr inbounds [14 x i8], [14 x i8]* @.str.msg.1, i64 0, i64 0
  %msg2_str_ptr = getelementptr inbounds [18 x i8], [18 x i8]* @.str.msg.2, i64 0, i64 0
  %msg3_str_ptr = getelementptr inbounds [17 x i8], [17 x i8]* @.str.msg.3, i64 0, i64 0

  %arg0 = add i64 10293450192, 0
  ; TYPE_DOUBLE = 4
  %arg1_tmp = call i8* @CreateSlice(i64 4)
  %arg1_tmp2 = call i8* (i8*, ...) @SliceAppend(i8* %arg1_tmp, double 410.32)
  %arg1 = call i8* (i8*, ...) @SliceAppend(i8* %arg1_tmp2, double -410.32)

  %arg2 = fadd double 1023.493, 0.0
  %arg3 = fadd double -3920.42, 0.0
  %arg4 = call i8* @CreateString(i8* %msg1_str_ptr)

  ; TYPE_STRING = 1
  %arg5_tmp = call i8* @CreateSlice(i64 1)

  %arg5_inner_str = call i8* @CreateString(i8* %msg1_str_ptr)
  %arg5_inner_str2 = call i8* @CreateString(i8* %msg2_str_ptr)
  %arg5_inner_str3 = call i8* @CreateString(i8* %msg3_str_ptr)

  %arg5_tmp2 = call i8* (i8*, ...) @SliceAppend(i8* %arg5_tmp, i8* %arg5_inner_str)
  %arg5_tmp3 = call i8* (i8*, ...) @SliceAppend(i8* %arg5_tmp2, i8* %arg5_inner_str2)
  %arg5 = call i8* (i8*, ...) @SliceAppend(i8* %arg5_tmp3, i8* %arg5_inner_str3)

  %arg6 = add i64 -100000, 0

  %future_obj = call i8* @digo_linker_async_call_func_shift_arg_and_slice(i64 %arg0, i8* %arg1, double %arg2, double %arg3, i8* %arg4, i8* %arg5, i64 %arg6)
  
  %retaggval = call {i8*, double, double, i8*, i8*, i64, i64} @digo_linker_await_func_shift_arg_and_slice(i8* %future_obj)

  %ret0 = extractvalue {i8*, double, double, i8*, i8*, i64, i64} %retaggval, 0
  %ret1 = extractvalue {i8*, double, double, i8*, i8*, i64, i64} %retaggval, 1
  %ret2 = extractvalue {i8*, double, double, i8*, i8*, i64, i64} %retaggval, 2
  %ret3 = extractvalue {i8*, double, double, i8*, i8*, i64, i64} %retaggval, 3
  %ret4 = extractvalue {i8*, double, double, i8*, i8*, i64, i64} %retaggval, 4
  %ret5 = extractvalue {i8*, double, double, i8*, i8*, i64, i64} %retaggval, 5
  %ret6 = extractvalue {i8*, double, double, i8*, i8*, i64, i64} %retaggval, 6

  %format_str2_ptr = getelementptr inbounds [47 x i8], [47 x i8]* @.str.format.2, i64 0, i64 0

  call void (i8*, ...) @println(i8* %format_str2_ptr, i8* %ret0, double %ret1, double %ret2, i8* %ret3, i8* %ret4, i64 %ret5, i64 %ret6)


  %future_obj2 = call i8* @digo_linker_async_call_func_add_int_100(i64 502)
  %retaggval2 = call {i64} @digo_linker_await_func_add_int_100(i8* %future_obj2)

  %retval2 = extractvalue {i64} %retaggval2, 0

  %str_ptr = getelementptr inbounds [3 x i8], [3 x i8]* @.str.format.0, i64 0, i64 0

  call void (i8*, ...) @println(i8* %str_ptr, i64 %retval2)

  ret void
}

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
