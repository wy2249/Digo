; ModuleID = 'src/serializer_template.cpp'
source_filename = "src/serializer_template.cpp"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: uwtable
define dso_local i32 @_Z19serializer_templatePcS_(i8* %0, i8* %1) local_unnamed_addr #0 {
  %3 = alloca i8*, align 8
  %4 = alloca i32, align 4
  %5 = tail call i8* @SW_CreateWrapper()
  tail call void @SW_AddInt32(i8* %5, i32 100)
  tail call void @SW_AddInt32(i8* %5, i32 100)
  tail call void @SW_AddInt64(i8* %5, i64 200)
  tail call void @SW_AddString(i8* %5, i8* %0)
  tail call void @SW_AddString(i8* %5, i8* %1)
  tail call void @SW_AddInt32(i8* %5, i32 2147483647)
  tail call void @SW_AddInt32(i8* %5, i32 -2147483648)
  tail call void @SW_AddInt64(i8* %5, i64 9223372036854775807)
  tail call void @SW_AddInt64(i8* %5, i64 -9223372036854775808)
  %6 = bitcast i8** %3 to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %6) #3
  store i8* null, i8** %3, align 8, !tbaa !2
  %7 = bitcast i32* %4 to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* nonnull %7) #3
  store i32 0, i32* %4, align 4, !tbaa !6
  call void @SW_GetAndDestroy(i8* %5, i8** nonnull %3, i32* nonnull %4)
  call void @llvm.lifetime.end.p0i8(i64 4, i8* nonnull %7) #3
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %6) #3
  ret i32 0
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

declare dso_local i8* @SW_CreateWrapper() local_unnamed_addr #2

declare dso_local void @SW_AddInt32(i8*, i32) local_unnamed_addr #2

declare dso_local void @SW_AddInt64(i8*, i64) local_unnamed_addr #2

declare dso_local void @SW_AddString(i8*, i8*) local_unnamed_addr #2

declare dso_local void @SW_GetAndDestroy(i8*, i8**, i32*) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { argmemonly nounwind willreturn }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.linker.options = !{}
!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0-4ubuntu1 "}
!2 = !{!3, !3, i64 0}
!3 = !{!"any pointer", !4, i64 0}
!4 = !{!"omnipotent char", !5, i64 0}
!5 = !{!"Simple C++ TBAA"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !4, i64 0}
