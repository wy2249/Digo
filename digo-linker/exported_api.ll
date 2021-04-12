
declare dso_local i8* @CreateString(i8*)
declare dso_local i8* @CreateEmptyString()
declare dso_local i8* @AddString(i8*, i8*)
declare dso_local i8* @AddCString(i8*, i8*)
declare dso_local i8* @CloneString(i8*)
declare dso_local i64 @CompareString(i8*, i8*)
declare dso_local i64 @GetStringSize(i8*)
declare dso_local i8* @GetCStr(i8*)

declare dso_local void @print(i8*, ...)
declare dso_local void @println(i8*, ...)

declare dso_local i8* @CreateSlice(i64)
declare dso_local i8* @SliceSlice(i8*, i64, i64)
declare dso_local i8* @SliceAppend(i8*, ...)
declare dso_local i8* @CloneSlice(i8*)
declare dso_local i64 @GetSliceSize(i8*)
