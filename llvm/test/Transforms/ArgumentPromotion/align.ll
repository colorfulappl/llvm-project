; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -argpromotion < %s | FileCheck %s

define internal i32 @callee_must_exec(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@callee_must_exec
; CHECK-SAME: (i32 [[P_VAL:%.*]]) {
; CHECK-NEXT:    ret i32 [[P_VAL]]
;
  %x = load i32, i32* %p, align 16
  ret i32 %x
}

define void @caller_must_exec(i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@caller_must_exec
; CHECK-SAME: (i32* [[P:%.*]]) {
; CHECK-NEXT:    [[P_VAL:%.*]] = load i32, i32* [[P]], align 16
; CHECK-NEXT:    [[TMP1:%.*]] = call i32 @callee_must_exec(i32 [[P_VAL]])
; CHECK-NEXT:    ret void
;
  call i32 @callee_must_exec(i32* %p)
  ret void
}

define internal i32 @callee_guaranteed_aligned_1(i1 %c, i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@callee_guaranteed_aligned_1
; CHECK-SAME: (i1 [[C:%.*]], i32 [[P_VAL:%.*]]) {
; CHECK-NEXT:    br i1 [[C]], label [[IF:%.*]], label [[ELSE:%.*]]
; CHECK:       if:
; CHECK-NEXT:    ret i32 [[P_VAL]]
; CHECK:       else:
; CHECK-NEXT:    ret i32 -1
;
  br i1 %c, label %if, label %else

if:
  %x = load i32, i32* %p, align 16
  ret i32 %x

else:
  ret i32 -1
}

define void @caller_guaranteed_aligned_1(i1 %c, i32* align 16 dereferenceable(4) %p) {
; CHECK-LABEL: define {{[^@]+}}@caller_guaranteed_aligned_1
; CHECK-SAME: (i1 [[C:%.*]], i32* align 16 dereferenceable(4) [[P:%.*]]) {
; CHECK-NEXT:    [[P_VAL:%.*]] = load i32, i32* [[P]], align 16
; CHECK-NEXT:    [[TMP1:%.*]] = call i32 @callee_guaranteed_aligned_1(i1 [[C]], i32 [[P_VAL]])
; CHECK-NEXT:    ret void
;
  call i32 @callee_guaranteed_aligned_1(i1 %c, i32* %p)
  ret void
}

define internal i32 @callee_guaranteed_aligned_2(i1 %c, i32* align 16 dereferenceable(4) %p) {
; CHECK-LABEL: define {{[^@]+}}@callee_guaranteed_aligned_2
; CHECK-SAME: (i1 [[C:%.*]], i32 [[P_VAL:%.*]]) {
; CHECK-NEXT:    br i1 [[C]], label [[IF:%.*]], label [[ELSE:%.*]]
; CHECK:       if:
; CHECK-NEXT:    ret i32 [[P_VAL]]
; CHECK:       else:
; CHECK-NEXT:    ret i32 -1
;
  br i1 %c, label %if, label %else

if:
  %x = load i32, i32* %p, align 16
  ret i32 %x

else:
  ret i32 -1
}

define void @caller_guaranteed_aligned_2(i1 %c, i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@caller_guaranteed_aligned_2
; CHECK-SAME: (i1 [[C:%.*]], i32* [[P:%.*]]) {
; CHECK-NEXT:    [[P_VAL:%.*]] = load i32, i32* [[P]], align 16
; CHECK-NEXT:    [[TMP1:%.*]] = call i32 @callee_guaranteed_aligned_2(i1 [[C]], i32 [[P_VAL]])
; CHECK-NEXT:    ret void
;
  call i32 @callee_guaranteed_aligned_2(i1 %c, i32* %p)
  ret void
}

; TODO: This should not be promoted, as the caller only guarantees that the
; pointer is dereferenceable, not that it is aligned.
define internal i32 @callee_not_guaranteed_aligned(i1 %c, i32* %p) {
; CHECK-LABEL: define {{[^@]+}}@callee_not_guaranteed_aligned
; CHECK-SAME: (i1 [[C:%.*]], i32 [[P_VAL:%.*]]) {
; CHECK-NEXT:    br i1 [[C]], label [[IF:%.*]], label [[ELSE:%.*]]
; CHECK:       if:
; CHECK-NEXT:    ret i32 [[P_VAL]]
; CHECK:       else:
; CHECK-NEXT:    ret i32 -1
;
  br i1 %c, label %if, label %else

if:
  %x = load i32, i32* %p, align 16
  ret i32 %x

else:
  ret i32 -1
}

define void @caller_not_guaranteed_aligned(i1 %c, i32* dereferenceable(4) %p) {
; CHECK-LABEL: define {{[^@]+}}@caller_not_guaranteed_aligned
; CHECK-SAME: (i1 [[C:%.*]], i32* dereferenceable(4) [[P:%.*]]) {
; CHECK-NEXT:    [[P_VAL:%.*]] = load i32, i32* [[P]], align 16
; CHECK-NEXT:    [[TMP1:%.*]] = call i32 @callee_not_guaranteed_aligned(i1 [[C]], i32 [[P_VAL]])
; CHECK-NEXT:    ret void
;
  call i32 @callee_not_guaranteed_aligned(i1 %c, i32* %p)
  ret void
}
