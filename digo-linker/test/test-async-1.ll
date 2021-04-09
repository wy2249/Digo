
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

; DIGO Async Function Metadata END

@.str = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

declare dso_local void @printFloat(double)
declare dso_local void @printInt(i32) 
declare dso_local void @printString(i8* nocapture readonly)


; THIS IS AN ASYNC FUNCTION
define {i64} @add_int_100(i64 %i) #0 {
  %add = add nsw i64 %i, 100

  %aggRet = insertvalue {i64} undef, i64 %add, 0
  ret {i64} %aggRet
}

define void @digo_main() {
entry:

  %future_obj = call i8* @digo_linker_async_call_func_add_int_100(i64 502)
  %retaggval = call {i64} @digo_linker_await_func_add_int_100(i8* %future_obj)

  %retval = extractvalue {i64} %retaggval, 0
  call void @JobDecRef(i8* %future_obj)

  %conv = trunc i64 %retval to i32

  call void @printInt(i32 %conv)
  ret void
}

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
