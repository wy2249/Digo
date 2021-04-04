
; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; DIGO Async Function Metadata BEGIN

; VERSION = 1

; FUNC DECLARE BEGIN
; FUNC_NAME = 'async_func_test_string_to_int'
; FUNC_ANNOT = 'async'
; PARAMETERS = 'string'
; RETURN_TYPE = 'int'
; FUNC DECLARE END

; DIGO Async Function Metadata END

@.str = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

@.str.test.num20 = private unnamed_addr constant [4 x i8] c"20\0A\00", align 1

; Function Attrs: nounwind readonly
declare dso_local i32 @atoi(i8*) #2

declare dso_local void @printFloat(double)
declare dso_local void @printInt(i32) 
declare dso_local void @printString(i8* nocapture readonly)


; THIS IS AN ASYNC FUNCTION
define i64 @async_func_test_string_to_int(i8* %arg_str_ref) #0 {
  %arg0 = call i8* @GetString(i8* %arg_str_ref)

  %r2 = alloca i8*, align 8
  store i8* %arg0, i8** %r2, align 8
  %r3 = load i8*, i8** %r2, align 8
  %r4 = call i32 @atoi(i8* %r3) #4
  
  %r5 = sext i32 %r4 to i64
  ret i64 %r5
}

define void @digo_main() {
entry:

  %future_obj = call i8* @digo_linker_async_call_func_async_func_test_string_to_int(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.test.num20, i64 0, i64 0))
  %retval = call i64 @digo_linker_await_func_async_func_test_string_to_int(i8* %future_obj)

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
