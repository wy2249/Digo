; ModuleID = 'llvm-link'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; DIGO Async Function Metadata BEGIN
; VERSION = 1
; FUNC DECLARE BEGIN
; FUNC_NAME = 'async_func_test_string_to_int'
; FUNC_ANNOT = 'async'
; PARAMETERS = 'string, int'
; RETURN_TYPE = 'int'
; FUNC DECLARE END
; DIGO Async Function Metadata END

@.str = private unnamed_addr constant [5 x i8] c"%lf\0A\00", align 1
@.str.1 = private unnamed_addr constant [4 x i8] c"%d\0A\00", align 1

@.str.test.num20 = private unnamed_addr constant [4 x i8] c"20\0A\00", align 1

@.str.async.func.name0 = private unnamed_addr constant [30 x i8] c"async_func_test_string_to_int\00", align 1

; Function Attrs: nounwind readonly
declare dso_local i32 @atoi(i8*) #2

declare dso_local void @AwaitJob(i8*, i8**, i32*)
declare dso_local void @JobDecRef(i8*)

declare dso_local i8* @CreateAsyncJob(i32, i8*, i32)
declare dso_local i8* @GetString(i8*)
declare dso_local void @SW_AddString(i8*, i8*)
declare dso_local void @SW_AddInt32(i8*, i32)
declare dso_local i8* @SW_CreateExtractor(i8*, i32)
declare dso_local i8* @SW_CreateWrapper()
declare dso_local i32 @SW_ExtractInt32(i8*)
declare dso_local i64 @SW_ExtractInt64(i8*)
declare dso_local i8* @SW_ExtractString(i8*)
declare dso_local void @SW_GetAndDestroy(i8*, i8**, i32*)
declare dso_local void @StringDecRef(i8*)
declare dso_local void @ASYNC_AddFunction(i32, i8* nocapture readonly)

declare dso_local void @printFloat(double)
declare dso_local void @printInt(i32) 
declare dso_local void @printString(i8* nocapture readonly)

declare dso_local void @Debug_Real_LinkerCallFunction(i32, i32)

declare i32 @printf(i8* nocapture readonly, ...) local_unnamed_addr #1


; THIS IS AN ASYNC FUNCTION
define i32 @async_func_test_string_to_int(i8* %arg0) #0 {
  %r2 = alloca i8*, align 8
  store i8* %arg0, i8** %r2, align 8
  %r3 = load i8*, i8** %r2, align 8
  %r4 = call i32 @atoi(i8* %r3) #4
  ret i32 %r4
}

define i8* @digo_linker_async_call_func_0(i8* %arg0) {
entry:
  %wrapper = call i8* @SW_CreateWrapper()
  call void @SW_AddString(i8* %wrapper, i8* %arg0)
  %result = alloca i8*, align 8
  %len = alloca i32, align 4

  call void @SW_GetAndDestroy(i8* %wrapper, i8** %result, i32* %len)

  %result_in = load i8*, i8** %result, align 8
  %len_in = load i32, i32* %len, align 4

  %future_obj = call i8* @CreateAsyncJob(i32 0, i8* %result_in, i32 %len_in)
  ret i8* %future_obj
}

define i32 @digo_linker_await_func_0(i8* %arg0) {
  %result = alloca i8*, align 8
  %len = alloca i32, align 4
  call void @AwaitJob(i8* %arg0, i8** %result, i32* %len)

  %result_in = load i8*, i8** %result, align 8
  %len_in = load i32, i32* %len, align 4

  %extractor = call i8* @SW_CreateExtractor(i8* %result_in, i32 %len_in)

  %ret = call i32 @SW_ExtractInt32(i8* %extractor)

  ret i32 %ret
}

define i32 @linker_call_function(i32 %func_id, i8* %arg, i32 %arg_len, i8** %result, i32* %result_len) {
  call void @Debug_Real_LinkerCallFunction(i32 %func_id, i32 %arg_len)

  %wrapper = call i8* @SW_CreateWrapper()
  %extractor = call i8* @SW_CreateExtractor(i8* %arg, i32 %arg_len)

  switch i32 %func_id, label %if.nomatch [
    i32 0, label %if.func0
    i32 1, label %if.func1
  ]

if.func0:
  %str_with_ref = call i8* @SW_ExtractString(i8* %extractor)
  %str = call i8* @GetString(i8* %str_with_ref)
  %call = call i32 @async_func_test_string_to_int(i8* %str)

  call void @StringDecRef(i8* %str_with_ref)

  call void @SW_AddInt32(i8* %wrapper, i32 %call)
  call void @SW_GetAndDestroy(i8* %wrapper, i8** %result, i32* %result_len)

  br label %if.nomatch

if.func1:
  br label %if.nomatch

if.nomatch:
  ret i32 0
}

define void @main() {
entry:
  call void @ASYNC_AddFunction(i32 0, i8* getelementptr inbounds ([30 x i8], [30 x i8]* @.str.async.func.name0, i64 0, i64 0))

  %future_obj = call i8* @digo_linker_async_call_func_0(i8* getelementptr inbounds ([4 x i8], [4 x i8]* @.str.test.num20, i64 0, i64 0))
  %retval = call i32 @digo_linker_await_func_0(i8* %future_obj)

  call void @JobDecRef(i8* %future_obj)

  call void @printInt(i32 %retval)
  ret void
}

attributes #0 = { noinline nounwind uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "no-frame-pointer-elim"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1}

!0 = !{!"clang version 6.0.0-1ubuntu2 (tags/RELEASE_600/final)"}
!1 = !{i32 1, !"wchar_size", i32 4}
