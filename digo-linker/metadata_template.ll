; ModuleID = 'src/serializer_template.cpp'
source_filename = "src/serializer_template.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.__va_list_tag = type { i32, i32, i8*, i8* }


; DIGO Async Function Metadata BEGIN
; VERSION = 1

; FUNC DECLARE BEGIN
; FUNC_NAME = 'func_1'
; PARAMETERS = 'int, string, string, int'
; RETURN_TYPE = 'int, string'
; FUNC DECLARE END

; FUNC DECLARE BEGIN
; FUNC_NAME = 'func_2'
; PARAMETERS = 'int,string, int'
; RETURN_TYPE = 'string, string'
; FUNC DECLARE END

; DIGO Async Function Metadata END


@.str = private unnamed_addr constant [6 x i8] c"func1\00", align 1

; Function Attrs: noinline optnone uwtable
define dso_local i32 @_Z19serializer_templatePcS_(i8* %str, i8* %str2) #0 {
entry:
  %str.addr = alloca i8*, align 8
  %str2.addr = alloca i8*, align 8
  %s = alloca i8*, align 8
  %result = alloca i8*, align 8
  %len = alloca i32, align 4
  store i8* %str, i8** %str.addr, align 8
  store i8* %str2, i8** %str2.addr, align 8
  %call = call i8* @SW_CreateWrapper()
  store i8* %call, i8** %s, align 8
  %0 = load i8*, i8** %s, align 8
  call void @SW_AddInt32(i8* %0, i32 100)
  %1 = load i8*, i8** %s, align 8
  call void @SW_AddInt32(i8* %1, i32 100)
  %2 = load i8*, i8** %s, align 8
  call void @SW_AddInt64(i8* %2, i64 200)
  %3 = load i8*, i8** %s, align 8
  %4 = load i8*, i8** %str.addr, align 8
  call void @SW_AddString(i8* %3, i8* %4)
  %5 = load i8*, i8** %s, align 8
  %6 = load i8*, i8** %str2.addr, align 8
  call void @SW_AddString(i8* %5, i8* %6)
  %7 = load i8*, i8** %s, align 8
  call void @SW_AddInt32(i8* %7, i32 2147483647)
  %8 = load i8*, i8** %s, align 8
  call void @SW_AddInt32(i8* %8, i32 -2147483648)
  %9 = load i8*, i8** %s, align 8
  call void @SW_AddInt64(i8* %9, i64 9223372036854775807)
  %10 = load i8*, i8** %s, align 8
  call void @SW_AddInt64(i8* %10, i64 -9223372036854775808)
  store i8* null, i8** %result, align 8
  store i32 0, i32* %len, align 4
  %11 = load i8*, i8** %s, align 8
  call void @SW_GetAndDestroy(i8* %11, i8** %result, i32* %len)
  %12 = load i8*, i8** %result, align 8
  call void @SW_FreeArray(i8* %12)
  ret i32 0
}

declare dso_local i8* @SW_CreateWrapper() #1

declare dso_local void @SW_AddInt32(i8*, i32) #1

declare dso_local void @SW_AddInt64(i8*, i64) #1

declare dso_local void @SW_AddString(i8*, i8*) #1

declare dso_local void @SW_GetAndDestroy(i8*, i8**, i32*) #1

declare dso_local void @SW_FreeArray(i8*) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @_Z19jump_table_templatePKcz(i8* %func_name, ...) #2 {
entry:
  %func_name.addr = alloca i8*, align 8
  %parameter_count = alloca i32, align 4
  %args = alloca [1 x %struct.__va_list_tag], align 16
  %i = alloca i32, align 4
  store i8* %func_name, i8** %func_name.addr, align 8
  store i32 0, i32* %parameter_count, align 4
  %0 = load i8*, i8** %func_name.addr, align 8
  %call = call i32 @strcmp(i8* getelementptr inbounds ([6 x i8], [6 x i8]* @.str, i64 0, i64 0), i8* %0) #5
  %cmp = icmp eq i32 %call, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  store i32 5, i32* %parameter_count, align 4
  br label %func1

if.end:                                           ; preds = %entry
  br label %func1

func1:                                            ; preds = %if.end, %if.then
  %arraydecay = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %args, i64 0, i64 0
  %arraydecay1 = bitcast %struct.__va_list_tag* %arraydecay to i8*
  call void @llvm.va_start(i8* %arraydecay1)
  store i32 0, i32* %i, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %func1
  %1 = load i32, i32* %i, align 4
  %2 = load i32, i32* %parameter_count, align 4
  %cmp2 = icmp slt i32 %1, %2
  br i1 %cmp2, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %arraydecay3 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %args, i64 0, i64 0
  %gp_offset_p = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay3, i32 0, i32 0
  %gp_offset = load i32, i32* %gp_offset_p, align 16
  %fits_in_gp = icmp ule i32 %gp_offset, 40
  br i1 %fits_in_gp, label %vaarg.in_reg, label %vaarg.in_mem

vaarg.in_reg:                                     ; preds = %for.body
  %3 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay3, i32 0, i32 3
  %reg_save_area = load i8*, i8** %3, align 16
  %4 = getelementptr i8, i8* %reg_save_area, i32 %gp_offset
  %5 = bitcast i8* %4 to i64*
  %6 = add i32 %gp_offset, 8
  store i32 %6, i32* %gp_offset_p, align 16
  br label %vaarg.end

vaarg.in_mem:                                     ; preds = %for.body
  %overflow_arg_area_p = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay3, i32 0, i32 2
  %overflow_arg_area = load i8*, i8** %overflow_arg_area_p, align 8
  %7 = bitcast i8* %overflow_arg_area to i64*
  %overflow_arg_area.next = getelementptr i8, i8* %overflow_arg_area, i32 8
  store i8* %overflow_arg_area.next, i8** %overflow_arg_area_p, align 8
  br label %vaarg.end

vaarg.end:                                        ; preds = %vaarg.in_mem, %vaarg.in_reg
  %vaarg.addr = phi i64* [ %5, %vaarg.in_reg ], [ %7, %vaarg.in_mem ]
  %8 = load i64, i64* %vaarg.addr, align 8
  %arraydecay4 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %args, i64 0, i64 0
  %gp_offset_p5 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay4, i32 0, i32 0
  %gp_offset6 = load i32, i32* %gp_offset_p5, align 16
  %fits_in_gp7 = icmp ule i32 %gp_offset6, 40
  br i1 %fits_in_gp7, label %vaarg.in_reg8, label %vaarg.in_mem10

vaarg.in_reg8:                                    ; preds = %vaarg.end
  %9 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay4, i32 0, i32 3
  %reg_save_area9 = load i8*, i8** %9, align 16
  %10 = getelementptr i8, i8* %reg_save_area9, i32 %gp_offset6
  %11 = bitcast i8* %10 to i8**
  %12 = add i32 %gp_offset6, 8
  store i32 %12, i32* %gp_offset_p5, align 16
  br label %vaarg.end14

vaarg.in_mem10:                                   ; preds = %vaarg.end
  %overflow_arg_area_p11 = getelementptr inbounds %struct.__va_list_tag, %struct.__va_list_tag* %arraydecay4, i32 0, i32 2
  %overflow_arg_area12 = load i8*, i8** %overflow_arg_area_p11, align 8
  %13 = bitcast i8* %overflow_arg_area12 to i8**
  %overflow_arg_area.next13 = getelementptr i8, i8* %overflow_arg_area12, i32 8
  store i8* %overflow_arg_area.next13, i8** %overflow_arg_area_p11, align 8
  br label %vaarg.end14

vaarg.end14:                                      ; preds = %vaarg.in_mem10, %vaarg.in_reg8
  %vaarg.addr15 = phi i8** [ %11, %vaarg.in_reg8 ], [ %13, %vaarg.in_mem10 ]
  %14 = load i8*, i8** %vaarg.addr15, align 8
  br label %for.inc

for.inc:                                          ; preds = %vaarg.end14
  %15 = load i32, i32* %i, align 4
  %inc = add nsw i32 %15, 1
  store i32 %inc, i32* %i, align 4
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %arraydecay16 = getelementptr inbounds [1 x %struct.__va_list_tag], [1 x %struct.__va_list_tag]* %args, i64 0, i64 0
  %arraydecay1617 = bitcast %struct.__va_list_tag* %arraydecay16 to i8*
  call void @llvm.va_end(i8* %arraydecay1617)
  br label %end

end:                                              ; preds = %for.end
  ret void
}

; Function Attrs: nounwind readonly
declare dso_local i32 @strcmp(i8*, i8*) #3

; Function Attrs: nounwind
declare void @llvm.va_start(i8*) #4

; Function Attrs: nounwind
declare void @llvm.va_end(i8*) #4

attributes #0 = { noinline optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #4 = { nounwind }
attributes #5 = { nounwind readonly }

!llvm.linker.options = !{}
!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
