#!/bin/bash
#--------------------------------------#
#Matricola: VR458240
#Nome e cognome: Muhamed Refati
#Data di realizzazione: 7 Dicembre 2021
#Titolo esercizio: Scheda Anagrafica
#--------------------------------------#

function menu {
	echo "Scelga il numero corrispondente all'azione da eseguire: "
	echo "1) Aggiungi studente"
	echo "2) Elimina studente"
	echo "3) Visualizza l'elenco"
	echo "4) Ricerca studente per cognome"
	echo "5) Ricerca il numero di iscritti per anno"
   	echo "6) Esporta passwd"
   	echo "7) Esci"
	read scelta
    choice  $scelta
}

function choice {
		case $1 in
			1|uno|UNO|Uno|"Aggiungi studente"|"aggiungi studente") Add_Student;;
			2|due|DUE|Due|"Elimina studente"|"elimina studente") Rm_Student;;
			3|tre|TRE|Tre|"Visualizza l'elenco"|"visualizza l'elenco") 	clear
			tput setaf 2; (echo "NOME;COGNOME;MATRICOLA;ANNO" && cat ~/$filename | sort -t";" -k 3) | column -t -s";"  
			tput sgr0;;		#uso echo "stringa" per evitare di usare sed o awk
			4|quattro|QUATTRO|Quattro|"Ricerca studente per cognome"|"ricerca studente per cognome") Search_Student;;
			5|cinque|CINQUE|Cinque|"Ricerca il numero di iscritti per anno"|"ricerca il numero di iscritti per anno") Year_Student;;
           	6|sei|SEI|Sei|"Esporta passwd"|"esporta passwd") E_Passwd;;
            7|sette|SETTE|Sette|Esci|esci|Uscire|uscire|USCIRE) COLUMNS=$(tput cols) 
			arv="--- Arrivederci ---" #passo la stringa da formattare da tput cols
			printf "%*s\n" $(((${#arv}+$COLUMNS)/2)) "$arv" #stampo la stringa formattata da columns/2 cioè centrata nel terminale
			exit;;
			*) clear
			echo "Valore non valido!"
			menu;;
			esac
		print
}

function Add_Student {
	clear
    echo "Inserisci il nome: "
    read nome_stud
	until [[  $nome_stud =~ [^0-9] ]]; #controllo che non vengano inseriti valori compresi tra 0-9, cioè richiedo solo lettere
	do
    	echo "La parola inserita contiene numeri! Sono permesse solo le lettere"
    	echo "Inserisci il nome: "
    	read nome_stud
	done
    echo "Inserisci il cognome: "
    read cognome_stud
	until [[  $cognome_stud =~ [^0-9] ]];
	do
    	echo "La parola inserita contiene numeri! Sono permesse solo le lettere"
    	echo "Inserisci il cognome: "
    	read cognome_stud
	done

    echo "Inserisci la matricola: "
    read n_matricola

	until ! [[  $n_matricola =~ [^0-9] ]]; #controllo che la matricola abbia solo lettere e non caratteri  come "VR" davanti
	do
    	echo "La matricola contiene delle lettere. Inserisci la matricola: "
    	read n_matricola
	done

	compare_var=${#n_matricola} #conto il numero di digits della matricola, è come se fossero le posizioni di un vettore
	while [[ $compare_var -gt 6 ]] || [[ $compare_var -lt 6 && $compare_var -gt 0 ]];
	do
    	echo "La matricola inserita ha una lunghezza non accettabile."
    	echo "La matricola deve essere di 6 numeri."
    	echo "Inserisci la matricola: "
    	read n_matricola
    	compare_var=${#n_matricola}
	done

	check_matricola $n_matricola #funzione per il controllo della matricola

    anno_insert #chiamo la funzione per l'anno
    
	echo $nome_stud";"$cognome_stud";"$n_matricola";"$n_corso >> ~/$filename #salvo la riga scritta in fondo (uso >> per aggiungere in fondo)
}

function check_matricola {
	if grep -nrq "$1" ~/$filename; then
		echo "Matricola già presente, impossibile completare l'inserimento."
		echo "Desidera: "
		echo "1) uscire dal programma"
		echo "2) ritornare al menu"
		read choice
		case $choice in
			1) COLUMNS=$(tput cols) 
			arv="--- Arrivederci ---" 
			printf "%*s\n" $(((${#arv}+$COLUMNS)/2)) "$arv"
			exit;;
			2) clear
            menu;;
			*) echo "Ha premuto una opzione non valida. La riporto al menù di scelta!"
			menu;;
		esac
	fi
}
#funzione che può diventare ricorsiva; dopo questa funzione viene chiamata la funzione print che svuota lo stack
function anno_insert {
    echo "Inserisci l'anno di corso: "
    read n_corso
    case $n_corso in
        1|uno|primo|UNO|PRIMO|Uno|Primo) n_corso=1;;
        2|due|secondo|DUE|SECONDO|Due|Secondo) n_corso=2;;
        3|tre|terzo|TRE|TERZO|Tre|Terzo) n_corso=3;;
        *) echo "Valore del corso non accettabile!"
        echo
        anno_insert;;
    esac
}

function Search_Student {
	clear
	echo "Inserisci il cognome da cercare: "
	read var_cgn
	echo
    if grep -iqrw "$var_cgn" ~/$filename; then
        (cat ~/$filename | grep -i "$var_cgn" | sort -k 1)>cognome_temp.txt #passo il file già ordinato per nome in modo alfabetico crescente ad un file temporaneo
        while IFS= read -r cognome;
	    do
        echo "Nome: $(echo $cognome | grep -iw $var_cgn | cut -d";" -f1)" #stampo riga per riga a livello del nome
        echo "Cognome: $(echo $cognome | grep -iw $var_cgn | cut -d";" -f2)" #stampo riga per riga a livello del cognome
        echo "Matricola: $(echo $cognome | grep -iw $var_cgn | cut -d";" -f3)"
        echo "Anno: $(echo $cognome | grep -iw $var_cgn | cut -d";" -f4)"
        echo
        done < cognome_temp.txt; #leggo dal file temporaneo i cognomi che ho trovato dal mio file
        rm cognome_temp.txt #cancello il file temporaneo
	else
		echo "Cognome $var_cgn non trovato.";
		echo "Gradisce: "
        echo "1) inserire questo studente"
        echo "2) cercare un nuovo studente"
	    echo "3) ritornare al menu"
	    echo "4) uscire"
		read stchoice
		case $stchoice in
			1|Uno|UNO|uno) clear
            Add_Student;;
			2|due|DUE|Due) clear
            Search_Student;;
			3|tre|TRE|Tre) clear
            menu;;
			4|quattro|QUATTRO|Quattro) clear
            COLUMNS=$(tput cols) 
		arv="--- Arrivederci ---" 
		printf "%*s\n" $(((${#arv}+$COLUMNS)/2)) "$arv"
		exit;;
		esac
	fi
}

function Year_Student {
    echo "Inserisca l'anno di cui desidera vedere il numero totale di iscritti oppure scriva "tutti" per visualizzare l'elenco intero: "
    read yearchoice
    case $yearchoice in
        1|uno|primo|UNO|PRIMO|Uno|Primo) var_1=$(cat ~/$filename | cut -d";" -f4 | grep -n "1" | wc -l)
        echo "Primo anno:$var_1";;
        2|due|secondo|DUE|SECONDO|Due|Secondo) var_2=$(cat ~/$filename | cut -d";" -f4 | grep -n "2" | wc -l)
        echo "Secondo anno: $var_2";;
        3|tre|terzo|TRE|TERZO|Tre|Terzo) var_3=$(cat ~/$filename | cut -d";" -f4 | grep -n "3" | wc -l)
        echo "Terzo anno: $var_3";;
        tutti|TUTTI|Tutti) var_1=$(cat ~/$filename | cut -d";" -f4 | grep -n "1" | wc -l)
		var_2=$(cat ~/$filename | cut -d";" -f4 | grep -n "2" | wc -l)
		var_3=$(cat ~/$filename | cut -d";" -f4 | grep -n "3" | wc -l)
		echo "Primo anno:$var_1"
		echo "Secondo anno:$var_2"
		echo "Terzo anno:$var_3";;
		*) clear
		echo "Valore inserito non accettabile!"
		Year_Student;;
    esac
	#il controllo sui numeri inseriti è fatto in modo che l'utente possa digitare sia il numero (1) che la parola (primo) tramite gli "|" nel case
	echo "Vuole controllare altri anni?"
	echo "1) Si"
	echo "2) No"
	read newyear
	case $newyear in
		1|uno|UNO|Uno|Si|SI|si) Year_Student;;
		2|due|DUE|Due|No|NO|no|*) ;; #esce dalla funzione e prosegue con la chiamata nella funzione choice a print
	esac
}

function Rm_Student {
	clear
	echo "Inserisci la matricola dello studente da rimuovere"
	read mtodel

	compare_var=${#mtodel} #passo il valore della matricola come numero di valori di una stringa
	
	if [[ $compare_var -gt "6" ]] || [[ $compare_var -lt "6" && $compare_var -gt "0" ]]; then #compara la lunghezza delle stringhe nell'intervallo 0<stringa<6
		echo "La matricola inserita ha una lunghezza non accettabile."
    	echo "La matricola deve essere di 6 numeri."
		while [[ $compare_var -gt 6 ]] || [[ $compare_var -lt 6 && $compare_var -gt 0 ]];
		do
    	echo "Inserisci la matricola: "
    	read mtodel
    	compare_var=${#mtodel}
		done
	elif grep -ihq "$mtodel" ~/$filename; then
		(cat ~/$filename | grep -i -h -v "$mtodel" | cut -f 1-4) > filerimossi.txt && echo "Matricola $mtodel rimossa"; #passo il file senza pattern su un file temporaneo
		echo
	else
		echo "Matricola $mtodel non presente"
		echo "Vuoi:"
		echo "1) Inserire lo studente con la presente matricola ($mtodel)"
		echo "2) Cercare una nuova matricola"
		echo "3) Ritornare al menu"
        echo "4) Uscire dal programma"
		read cdel
		case $cdel in
			1|uno|UNO|Uno|"Inserire la matricola") Add_Student;;
			2|due|DUE|Due|"Cercare una nuova matricola") Rm_Student;;
			3|tre|TRE|Tre) menu;;
			4|quattro|Quattro|QUATTRO|*) COLUMNS=$(tput cols) 
			arv="--- Arrivederci ---" 
			printf "%*s\n" $(((${#arv}+$COLUMNS)/2)) "$arv"
			exit;;
		esac
	fi
    # incollo il file a cui ho rimosso il pattern
    cp filerimossi.txt ~/$filename
    rm filerimossi.txt #elimino il file temporaneo

	echo "Vuoi visualizzare il nuovo elenco modificato?"
	echo "1) Si"
	echo "2) No"
	read clist
	case $clist in
		Si|si|SI|1|Uno|UNO|Uno) tput setaf 3; (echo "NOME;COGNOME;MATRICOLA;ANNO" && cat ~/$filename | sort -t";" -k 3) | column -t -s";"
					tput sgr0;;
		No|no|NO|2|Due|DUE|Due) ;;
	esac
}

function E_Passwd {
	clear
	echo "Questa funzione le permetterà di esportare il file similmente al file passwd"
	echo 
    echo "NB: L'ambiente linux chiama la cartella 'Desktop' come 'Scrivania!"
    echo "Dove vuole salvarlo? Indichi il percorso esistente con /Cartella/Cartella/Nome_File.txt : "
    read dirchoice
    echo "Indichi lo UID di partenza: "
    read UIDchoice
    echo "Indichi il gruppo di appartenenza: "
    read groupchoice
	shell_choice #chiamo la funzione per leggere e cercare la shell
	var_tail=1 #var che conta per tagliare il file esportato a seconda del numero totali di cicli che il while esegue

	while IFS= read -r aumenta #while che legge da inizio a fine file
	do
        var_nome=$(echo $aumenta | cut -f 1 -d";") 
        var_cognome=$(echo $aumenta | cut -f 2 -d";")
        var_matricola=$(echo $aumenta | cut -f 3 -d";")
        echo $var_matricola/"x"/$UIDchoice":"$groupchoice":"/$var_cognome,$var_nome$dirchoice":"$shellchoice >> ~/$dirchoice
		UIDchoice=$((UIDchoice+1))
		var_tail=$((var_tail+1))
        done < ~/$filename;
    tail -${var_tail} ~/$dirchoice > my_temp_passwd.txt
    cp my_temp_passwd.txt ~/$dirchoice
    rm my_temp_passwd.txt
	echo "Ecco come è stato esportato il file: "
    tput setaf 6; cat ~/$dirchoice
	tput sgr0;
}

function shell_choice {
	echo "Indichi la shell ad essi associata: "
    read shellchoice
	if grep -nqriw "$shellchoice" /etc/passwd || grep -nqriw "$shellchoice" /etc/shells; then
		echo
		echo "Okay, shell trovata!"
		echo
	else
		echo
		echo "Questo path per la shell non è presente!"
		echo
		echo "Queste sono alcune tra le opzioni da cui è possibile selezionare. Scelga quella di suo gradimento: "
		cat /etc/passwd | tail -10 | cut -d"/" -f 2-10
		shell_choice
	fi
	return 0 #svuoto lo stack, nel caso faccia ricorsione
}

function print {
	echo
	echo "Vuole ritornare al menu di partenza oppure uscire?"
	echo "1) Ritorno al menu"
	echo "2) Uscire"
	read opt
	case $opt in
		1|"Ritorno al menu"|"ritorno al menu") clear
        menu;;
		2|"uscire"|"USCIRE"|"Uscire") COLUMNS=$(tput cols) 
		arv="--- Arrivederci ---" 
		printf "%*s\n" $(((${#arv}+$COLUMNS)/2)) "$arv"
		exit;;
		*) echo "Comando non corretto, esco dal programma!"
		echo
		COLUMNS=$(tput cols) 
		arv="--- Arrivederci ---" 
		printf "%*s\n" $(((${#arv}+$COLUMNS)/2)) "$arv"
		exit;;
	esac
    return 0
}

clear
COLUMNS=$(tput cols) 
scd="--- Scheda Anagrafica ---" 
printf "%*s\n" $(((${#scd}+$COLUMNS)/2)) "$scd"
echo "Questo script la aiuterà nella gestione dell'archivio degli studenti di UniVR"
filename=$1

if [[ -z $filename ]]; then #se non viene inserito nessun file, cioè se la variabile filename è vuot (flag -z) allora creo la directory e copio il mio file in quella cartella
mkdir ~/Scrivania/VR458240.Refati.Muhamed #creo la dir
cp file_test.csv ~/Scrivania/VR458240.Refati.Muhamed/filetest.csv #copio il file nel path predefinito
filename="/Scrivania/VR458240.Refati.Muhamed/filetest.csv" #passo il mio file preimpostato all'interno di filename
fi

menu $filename
print