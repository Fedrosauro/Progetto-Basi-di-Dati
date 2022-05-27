## Progetto Basi di Dati
### Gestione Ferroviaria R&F
Repository contenente i file delle *pagine web* inerenti al sito creato. Per l'interazione tra PHP e MySQL è stata usata la libreria **PDO** (PHP Data Object) la quale  sfrutta un approccio basato sul paradigma orientato agli oggetti. `$connection` è l'oggetto PDO che verrà creato per poi essere usato nelle *operazioni SQL*.

Il Sito Web è composto da 3 pagine : **Homepage**, **Operazioni SQL**, e **Tabelle**. Nel caso in cui si volesse confrontare i risultati delle operazioni sql con i dati nelle tabelle, si consiglia di aprire le pagine "Operazioni SQL" e "Tabelle" in 2 tab separati.

*Osservazione* : l'Host Provider (Infinity Free) per gli account non premium non consente di utilizzare Stored Procedures e Triggers. A causa di ciò, nel codice PHP sono state usate delle query normali per fare le operazioni sql.

Link al sito → [GestioneFerroviariaR&F](https://regionaliandfrecceprogettobdd.epizy.com/)
