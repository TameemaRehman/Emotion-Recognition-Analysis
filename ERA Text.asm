INCLUDE Irvine32.inc
INCLUDE macros.inc

search_word PROTO, search:PTR BYTE
BUFFER_SIZE=50000
.data

    buffer BYTE BUFFER_SIZE DUP(?)
    temp BYTE 10000 dup(?)
    temp2 BYTE 10000 dup(?)
    milliseconds DWORD 3000
    new_line byte 0Dh,0Ah
    
    input_str BYTE BUFFER_SIZE DUP (0)

    huz byte "Your Emotion suggests that you are Satisfied!",0,0,0,0,0
     byte "Your Emotion suggests that you are Gratified!",0,0,0,0,0
     byte "Your Emotion suggests that you are Joyful!",0,0,0,0,0,0,0,0
     byte "Your Emotion suggests that you are Dissatisfied!",0,0
     byte "Your Emotion suggests that you are Frustrated!",0,0,0,0
     byte  "Your Emotion suggests that you are Disappointed!",0,0

    input_str_len DWORD ?
    buffer_s DWORd ?
    ;rowsize DWORD ?

    Satisfaction byte BUFFER_SIZE DUP(0)
    Gratitude byte BUFFER_SIZE DUP(0)
    Dissatisfaction byte BUFFER_SIZE DUP(0)
    Joy byte BUFFER_SIZE DUP(0)
    Frustration byte BUFFER_SIZE DUP(0)
    Disappointment byte BUFFER_SIZE DUP(0)

    tameema DWORD 2500

    emotions DWORD OFFSET Satisfaction,OFFSET Gratitude,OFFSET Joy,OFFSET Dissatisfaction,OFFSET Frustration,OFFSET Disappointment
    array DWORD 6 DUP(0)
    emotion_size DWORD 6 DUP(?)
    counter DWORD ?
    positiveC DWORD 0
    negativeC DWORD 0
    EmotionC DWORD 0

    FileNames byte  "Satisfaction.txt",0,0,0,0
     rowsize = $ - FileNames
     byte  "Gratitude.txt",0,0,0,0,0,0,0
     byte  "Joy.txt",0,0,0,0,0,0,0,0,0,0,0,0,0
     byte  "Dissatisfaction.txt",0
     byte  "Frustration.txt",0,0,0,0,0
     byte  "Disappointment.txt",0,0

    filename byte 20 dup(0)
    fileHandle HANDLE ?

.code
main PROC

    mov eax, magenta + (yellow * 16)
    call setTextColor
    call clrscr
    call crlf
    call crlf
    call crlf
    call crlf
    call crlf
    call crlf
    call crlf
    call crlf
    call crlf
    call crlf

    mwrite "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    call crlf
    call crlf
    mwrite "                                             :) WELCOME TO EMOTIONS RECOGNITION ANALYSIS (:"
    call crlf
    call crlf
    mwrite "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="

    mov eax, milliseconds
    call delay
    call crlf
    call clrscr
    mwrite ".............................................................................................................."
    call crlf
    mwrite "DISCLAIMER: This disclaimer serves to clarify that the purpose of this application is to enable the company to analyze customer feedback, discerning between positive and negative sentiments for continuous improvement."
    call crlf
    mwrite "..............................................................................................................."
    mov eax, 1000
    call delay 
    call crlf
    call crlf
    mwrite "We genuinely care about your experience with us! Whether it's positive or areas where we can improve, your feedback is crucial. Could you kindly share your thoughts so we can continue to enhance our services?"
    call crlf
    
    mov ecx,6
    mov ebx,0 ;rows

    fill_arrays:
        push ecx
        mov edx,OFFSET FileNames
        mov eax,ebx
        mov edi,rowsize
        imul eax,edi
        add edx,eax
    
        call OpenInputFile
        mov fileHandle,eax

        ;read from file and store in their respective strings/arrays
        mov edx,emotions[ebx*TYPE emotions]
        mov ecx,BUFFER_SIZE
        call ReadFromFile
    
        mov emotion_size[ebx*TYPE emotion_size],eax
        mov eax,fileHandle
        call CloseFile

        inc ebx
        pop ecx
    LOOP fill_arrays



    ;-->input module
    call crlf
    mov edx,OFFSET input_str
    mov ecx,BUFFER_SIZE
    call ReadString
    call crlf
    mov input_str_len,eax
    mov ecx,eax
    mov esi, OFFSET input_str

    ;--->converting all characters to lower case
    UpperCase_to_LowerCase:
    mov al,[esi]
    cmp al,65
    jb nx
    cmp al,0
    je done
    cmp al,90
    ja nx
    add al,32
    mov [esi],al

    nx:
        inc esi
        loop UpperCase_to_LowerCase

    done:
        mov ecx,input_str_len
        inc ecx
        mov input_str[ecx]," "
        mov ebx,0
        mov edi, OFFSET temp
        L1:
            push ecx

            mov al,input_str[ebx]
            cmp al," "               ;space written
            jne L2

            ;temp has a word of the string
            push ebx

            invoke search_word,ADDR temp

            pop ebx

            ;clearing temp
            mov  ecx, SIZEOF temp
            mov  edi, OFFSET temp
            mov  al,0
            rep stosb
            mov  edi, OFFSET temp
            inc ebx
            mov al,input_str[ebx]
            L2:
                stosb
                inc ebx
                pop ecx
        LOOP L1

   
    mov esi,Offset array
    mov ecx, 6
    mov EmotionC,0
    SLoop:
        mov eax, [esi]
        cmp eax, 0
        je next
        
        mov eax,EmotionC
        imul eax,50
        mov edx,offset huz
        add edx,eax
        call writestring
        call crlF
            
    next:
    inc EmotionC
    add esi, 4
    
   loop SLoop
        
        
     SL:
        mov esi,Offset array
        mov eax, 0
        add eax, [esi]
        add eax, [esi+4]
        add eax, [esi+8]
        mov positiveC, eax

        mov eax, 0
        add eax, [esi+12]
        add eax, [esi+16]
        add eax, [esi+20]
        mov negativeC, eax
        call crlf
        mov eax, positiveC
        mwrite "Positive "
        call writeDec
        call crlF

        call crlf

        mov eax, negativeC
        mwrite "Negative "
        call writeDec
        call crlf

        mov eax, positiveC
        mov ebx, negativeC
        cmp eax, ebx
        je equalC
        ja greaterC
        jb lesserC

        equalC:
            mov eax, 2000
            call delay
            call crlf
            mwrite "Your FeedBack suggests a Neutral Feedback :| "
            call crlf
            mwrite "Thank you for taking the time to share your thoughts with us. We truly value your feedback."
            call crlf
            exit

        greaterC:
            mov eax, 2000
            call delay
            call crlf
            mwrite "Your FeedBack suggests a Positive Feedback :) "
            mwrite "We are glad that you loved working with us!!!"
            call crlf
            mwrite "Thank you for taking the time to share your thoughts with us. We truly value your feedback."
            call crlf
            exit

        lesserC:
            mov eax, 2000
            call delay
            call crlf
            mwrite "Your FeedBack suggests a Negative Feedback :( "
            mwrite "We will surely work upon areas that reuqire improvement to make your experiene better!!!"
            call crlf
            mwrite "Thank you for taking the time to share your thoughts with us. We truly value your feedback."
            call crlf
            exit
exit
main ENDP

;Search Word Procedure
search_word PROC, search:PTR BYTE

    mov ecx,6
    mov counter,0
    iteration:
        push ecx
        mov eax, counter
        mov ecx, emotion_size[eax*TYPE emotion_size]
        ;mov ecx,tameema
        mov ebx,0
        mov edi, OFFSET temp2
        mov esi, emotions[eax*TYPE emotions]
        L1:
            push ecx
            mov al,[esi]
            cmp al," "
            jne L2
        
            ;string comparison
            INVOKE str_compare, ADDR temp2, search
            jne not_found
        
            ;word mil gaya
 
            jmp L

            not_found:
                ;clearing temp
                mov  ecx, SIZEOF temp2
                mov  edi, OFFSET temp2
                mov  al,0
                rep stosb
                mov  edi, OFFSET temp2
                add esi,3
                mov al,[esi]
            L2:
                stosb
                inc esi
                pop ecx
        LOOP L1

        inc counter
        inc esi
        pop ecx
    LOOP iteration
    ret
    L:
        ;intensity is in al for that word
        inc esi
        mov al,[esi]
        
        sub al,48
        mov ebx,counter
        cmp ebx,6
        jne below
        dec ebx
        below:
        add BYTE PTR array[ebx*TYPE array],al
    ret
search_word ENDP
END main

