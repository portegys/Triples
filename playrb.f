      SUBROUTINE PLAYRB(POSA,POSB,RULTAB,RET)
C
C THIS SUBROUTINE MAKES A TRIPLES MOVE USING A
C VARIABLE PLY MINIMAX LOOK-AHEAD WITH ALPHA-BETA PRUNING.
C
      INTEGER RULTAB(5,5,6),POSA,POSB,RET
      COMMON ALOCX(9),ALOCY(9),BLOCX(9),BLOCY(9),
     1TURN,LVLPTR,VALUE(9),VALDEF(9),
     2MOVNDX(9),MOVSAV(9),MOVCNT(9),DEADLK,LVLIM
      INTEGER RULTBL(5,5,6)
      INTEGER ALOCX,ALOCY,BLOCX,BLOCY
      INTEGER TURN,LVLPTR,VALDEF
      INTEGER MOVNDX,MOVSAV,MOVCNT,DEADLK,LVLIM
      INTEGER X,Y,NUM
      REAL VALUE
      INTEGER I,J,Q,MOVE
C
C COPY RULTBL TO LOCAL AREA: THE NEED TO DO THIS IS CAUSED
C BY A STRANGE PROBLEM IN THE F77 UNIX COMPILER, WHICH 
C MAPS LOCAL VARIABLES, IE LVLIDX, ONTO THE INPUT ARRAY.
C
      DO 103 I=1,5,1
      DO 102 J=1,5,1
      DO 101 Q=1,6,1
      RULTBL(J,I,Q) = RULTAB(J,I,Q)
101   CONTINUE
102   CONTINUE
103   CONTINUE
C
C INITIALIZE THE FIRST LEVEL.
      LVLPTR = 1
      TURN = 1
      LVLIM = 9
      DEADLK = 0
      VALUE(1) = 0
      VALDEF(1) = 0
      MOVNDX(1) = 0
      MOVSAV(1) = 0
      MOVCNT(1) = 0
C
C SET THE POSITIONS OF THE PLAYERS.
      X = 0
      Y = 0
      NUM = POSA
1     IF (NUM.LT.5) GO TO 2
      NUM = NUM - 5
      Y = Y + 1
      GO TO 1
2     X = NUM
      ALOCX(1) = X + 1
      ALOCY(1) = Y + 1
      X = 0
      Y = 0
      NUM = POSB
3     IF (NUM.LT.5) GO TO 4
      NUM = NUM - 5
      Y = Y + 1
      GO TO 3
4     X = NUM
      BLOCX(1) = X + 1
      BLOCY(1) = Y + 1
C
C WHEN RETURN FROM TOP LEVEL, SEARCH IS COMPLETE.
5     IF (LVLPTR.EQ.0) GO TO 100
C
C TEST FOR TERMINAL NODE IN GAME TREE.
      IF (LVLPTR.EQ.LVLIM) GO TO 80
      IF (ALOCX(LVLPTR).EQ.5.AND.ALOCY(LVLPTR).EQ.1) GO TO 80
      IF (BLOCX(LVLPTR).EQ.1.AND.BLOCY(LVLPTR).EQ.1) GO TO 80
C
C COMPUTE THE PLAYER TURN AT THIS LEVEL.
      IF (TURN.EQ.0) GO TO 7
      IF (LVLPTR.EQ.1.OR.LVLPTR.EQ.3) GO TO 6
      IF (LVLPTR.EQ.5.OR.LVLPTR.EQ.7) GO TO 6
      MOVE = 0
      GO TO 9
6     MOVE = 1
      GO TO 9
7     IF (LVLPTR.EQ.1.OR.LVLPTR.EQ.3) GO TO 8
      IF (LVLPTR.EQ.5.OR.LVLPTR.EQ.7) GO TO 8
      MOVE = 1
      GO TO 9
8     MOVE = 0
C
C CHECK FOR A CUTOFF CONDITION.
9     IF (MOVCNT(LVLPTR).EQ.0.OR.MOVNDX(LVLPTR).GE.3) GO TO 14
      I = LVLPTR - 1
      IF (MOVE.EQ.1) GO TO 12
10    IF (I.LT.1.OR.MOVNDX(LVLPTR).EQ.3) GO TO 14
      IF (VALUE(I).LT.VALUE(LVLPTR).OR.MOVCNT(I).LE.1) GO TO 11
      MOVNDX(LVLPTR) = 3
11    I = I - 2
      GO TO 10
12    IF (I.LT.1.OR.MOVNDX(LVLPTR).EQ.3) GO TO 14
      IF (VALUE(I).GT.VALUE(LVLPTR).OR.MOVCNT(I).LE.1) GO TO 13
      MOVNDX(LVLPTR) = 3
13    I = I - 2
      GO TO 12
C
C TEST FOR END OF MOVES.
14    MOVNDX(LVLPTR) = MOVNDX(LVLPTR) + 1
      IF (MOVNDX(LVLPTR).LT.4) GO TO 20
C
C CHECK FOR A DEADLOCK AT THIS LEVEL.
      IF (MOVNDX(LVLPTR).EQ.4.AND.MOVCNT(LVLPTR).EQ.0) GO TO 15
C
C PERFORM THE MINIMAX PROCEDURE AT THE NEXT HIGHER LEVEL.
      CALL MINMAX
      LVLPTR = LVLPTR - 1
      GO TO 90
15    ALOCX(LVLPTR+1) = ALOCX(LVLPTR)
      ALOCY(LVLPTR+1) = ALOCY(LVLPTR)
      BLOCX(LVLPTR+1) = BLOCX(LVLPTR)
      BLOCY(LVLPTR+1) = BLOCY(LVLPTR)
      LVLPTR = LVLPTR + 1
      VALUE(LVLPTR) = 0
      VALDEF(LVLPTR) = 0
      MOVNDX(LVLPTR) = 0
      MOVSAV(LVLPTR) = 0
      MOVCNT(LVLPTR) = 0
      GO TO 90
C
C CHECK IF THE INDICATED MOVE CAN BE MADE.
20    IF (MOVE.EQ.1) GO TO 22
      I = BLOCX(LVLPTR)
      J = BLOCY(LVLPTR)
      GO TO 25
22    I = ALOCX(LVLPTR)
      J = ALOCY(LVLPTR)
      GO TO 30
25    IF ((ALOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))).GT.5) GO TO 90
      IF ((ALOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))).LT.1) GO TO 90
      IF ((ALOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)).GT.5) GO TO 90
      IF ((ALOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)).LT.1) GO TO 90
      IF ((ALOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))).NE.3) GO TO 26
      IF ((ALOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)).EQ.3) GO TO 90
26    Q = (ALOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)))
      IF (Q.NE.BLOCX(LVLPTR)) GO TO 40
      Q = (ALOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3))
      IF (Q.EQ.BLOCY(LVLPTR)) GO TO 90
      GO TO 40
30    IF ((BLOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))).GT.5) GO TO 90
      IF ((BLOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))).LT.1) GO TO 90
      IF ((BLOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)).GT.5) GO TO 90
      IF ((BLOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)).LT.1) GO TO 90
      IF ((BLOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))).NE.3) GO TO 31
      IF ((BLOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)).EQ.3) GO TO 90
31    Q = (BLOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)))
      IF (Q.NE.ALOCX(LVLPTR)) GO TO 40
      Q = (BLOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3))
      IF (Q.EQ.ALOCY(LVLPTR)) GO TO 90
C
C MAKE THE MOVE.
40    MOVCNT(LVLPTR) = MOVCNT(LVLPTR) + 1
      IF (MOVE.EQ.0) GO TO 43
      BLOCX(LVLPTR+1) = BLOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))
      BLOCY(LVLPTR+1) = BLOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)
      ALOCX(LVLPTR+1) = ALOCX(LVLPTR)
      ALOCY(LVLPTR+1) = ALOCY(LVLPTR)
      GO TO 45
43    ALOCX(LVLPTR+1) = ALOCX(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR))
      ALOCY(LVLPTR+1) = ALOCY(LVLPTR)+RULTBL(I,J,MOVNDX(LVLPTR)+3)
      BLOCX(LVLPTR+1) = BLOCX(LVLPTR)
      BLOCY(LVLPTR+1) = BLOCY(LVLPTR)
C
C INITIALIZE THE NEXT LEVEL.
45    LVLPTR = LVLPTR + 1
      VALUE(LVLPTR) = 0
      VALDEF(LVLPTR) = 0
      MOVNDX(LVLPTR) = 0
      MOVSAV(LVLPTR) = 0
      MOVCNT(LVLPTR) = 0
      GO TO 90
C
C THIS IS A TERMINAL LEVEL, DUE TO THE LOOK-AHEAD PLY LIMIT, OR
C AN END-GAME CONDITION.
80    CALL EVALUE
      CALL MINMAX
      LVLPTR = LVLPTR - 1
90    GO TO 5
C
C CHECK IF A MOVE CAN BE MADE ON THIS TURN.
100   IF (MOVSAV(1).NE.4) GO TO 105
      DEADLK = DEADLK + 1
      IF (TURN.EQ.0) GO TO 106
      J = POSB
      GO TO 110
106   J = POSA
      GO TO 110
105   DEADLK = 0
C
C MOVE THE INDICATED PIECE.
      IF (TURN.EQ.0) GO TO 107
      BLOCX(1) = BLOCX(1)+RULTBL(ALOCX(1),ALOCY(1),MOVSAV(1))
      BLOCY(1) = BLOCY(1)+RULTBL(ALOCX(1),ALOCY(1),MOVSAV(1)+3)
      J = ((BLOCX(1) - 1) + ((BLOCY(1) - 1) * 5))
      GO TO 110
107   ALOCX(1) = ALOCX(1)+RULTBL(BLOCX(1),BLOCY(1),MOVSAV(1))
      ALOCY(1) = ALOCY(1)+RULTBL(BLOCX(1),BLOCY(1),MOVSAV(1)+3)
      J = ((ALOCX(1) - 1) + ((ALOCY(1) - 1) * 5))
110   RET = J
C
C COPY THE LOCAL RULTBL BACK ONTO THE MANGLED INPUT
C TABLE.
C
      DO 152 I=1,5,1
      DO 151 J=1,5,1
      DO 150 Q=1,6,1
      RULTAB(J,I,Q) = RULTBL(J,I,Q)
150   CONTINUE
151   CONTINUE
152   CONTINUE
      RETURN
      END
      SUBROUTINE MINMAX
C
C THIS SUBROUTINE PERFORMS THE MINIMAX PROCEDURE OF BRINGING VALUES
C FROM TERMINAL LEVELS UP THROUGH THE GAME TREE.
C
      COMMON ALOCX(9),ALOCY(9),BLOCX(9),BLOCY(9),
     1TURN,LVLPTR,VALUE(9),VALDEF(9),
     2MOVNDX(9),MOVSAV(9),MOVCNT(9),DEADLK,LVLIM
      INTEGER ALOCX,ALOCY,BLOCX,BLOCY
      INTEGER TURN,LVLPTR,VALDEF
      INTEGER MOVNDX,MOVSAV,MOVCNT,DEADLK,LVLIM
      REAL VALUE
      INTEGER I,J,TLVL
C
C CHECK IF THE MINIMAX IS COMPLETE.
      TLVL = LVLPTR - 1
      IF (TLVL.EQ.0) GO TO 100
C
C CHECK IF ANY VALUE HAS BEEN BROUGHT UP TO THIS LEVEL BEFORE.
      IF (VALDEF(TLVL).EQ.1) GO TO 15
      VALUE(TLVL) = VALUE(TLVL+1)
      VALDEF(TLVL) = 1
      MOVSAV(TLVL) = MOVNDX(TLVL)
12    FORMAT (1H ,1I2,1H ,1I2,1H ,1I2,1H ,1I2)
      GO TO 100
C
C CHECK FOR MIN OR MAX LEVEL.
15    IF (TLVL.EQ.1.OR.TLVL.EQ.3) GO TO 45
      IF (TLVL.EQ.5.OR.TLVL.EQ.7) GO TO 45
C
C CHECK FOR A LESSER VALUE AT THE MIN LEVEL.
      IF (VALUE(TLVL).LE.VALUE(TLVL+1).AND.MOVCNT(TLVL).GE.2) GO TO 100
C
C BRING UP THE LESSER VALUE.
      VALUE(TLVL) = VALUE(TLVL+1)
      MOVSAV(TLVL) = MOVNDX(TLVL)
      GO TO 100
C
C PROCESS THE MAX LEVEL.
45    IF (VALUE(TLVL).GE.VALUE(TLVL+1).AND.MOVCNT(TLVL).GE.2) GO TO 100
C
C BRING UP THE GREATER VALUE.
      VALUE(TLVL) = VALUE(TLVL+1)
      MOVSAV(TLVL) = MOVNDX(TLVL)
C
100   RETURN
      END
      SUBROUTINE EVALUE
C
C THIS SUBROUTINE EVALUATES THE TERMINAL BOARD GIVEN TO IT USING A
C HEURISTIC EVALUATION FUNCTION.
C
      COMMON ALOCX(9),ALOCY(9),BLOCX(9),BLOCY(9),
     1TURN,LVLPTR,VALUE(9),VALDEF(9),
     2MOVNDX(9),MOVSAV(9),MOVCNT(9),DEADLK,LVLIM
      INTEGER ALOCX,ALOCY,BLOCX,BLOCY
      INTEGER TURN,LVLPTR,VALDEF
      INTEGER MOVNDX,MOVSAV,MOVCNT,DEADLK,LVLIM
      REAL VALUE
      INTEGER WIN
      REAL D1,D2,D2T
C
C TEST FOR A WIN BY EITHER PLAYER.
      WIN = 3
      IF (BLOCX(LVLPTR).EQ.1.AND.BLOCY(LVLPTR).EQ.1) WIN = 1
      IF (ALOCX(LVLPTR).EQ.5.AND.ALOCY(LVLPTR).EQ.1) WIN = 0
      IF (WIN.EQ.3) GO TO 20
      IF (TURN.EQ.0) GO TO 15
      IF (WIN.EQ.0) VALUE(LVLPTR) = -1000
      IF (WIN.EQ.1) VALUE(LVLPTR) = 1000
      GO TO 100
15    IF (WIN.EQ.0) VALUE(LVLPTR) = 1000
      IF (WIN.EQ.1) VALUE(LVLPTR) = -1000
      GO TO 100
C
C COMPUTE THE DISTANCES TO THE GOAL FOR THE PLAYERS.
20    D1 = SQRT(FLOAT((ALOCX(LVLPTR)-5)**2+(ALOCY(LVLPTR)-1)**2))
      D2 = SQRT(FLOAT((BLOCX(LVLPTR)-1)**2+(BLOCY(LVLPTR)-1)**2))
      IF (TURN.EQ.0) GO TO 30
C
C THIS IS THE EVALUATION STRATEGY CODE FOR PLAYER B.
      VALUE(LVLPTR) = D1 - D2
      D2T = SQRT(FLOAT((BLOCX(1)-1)**2+(BLOCY(1)-1)**2))
      VALUE(LVLPTR) = VALUE(LVLPTR) + (D2T - D2)
      GO TO 100
C
C THIS IS THE EVALUATION STRATEGY CODE FOR PLAYER A.
30    VALUE(LVLPTR) = D2 - D1
C
100   VALDEF(LVLPTR) = 1
      RETURN
      END
