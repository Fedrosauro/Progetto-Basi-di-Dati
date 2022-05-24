<?php
require_once 'config.php';
try{
    $connection = new PDO("mysql:host=$host;dbname=$db",$user,$password);
?>

<!DOCTYPE html> <!-- inizia ad arrivare la pagina web quindi if prima dell'HTML -->
<html>
  <head>
    <meta charset="utf-8">
    <title>Operazioni SQL</title>
    <link rel="stylesheet" href="style.css?v=<?php $version ?>">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400&display=swap" rel="stylesheet">
    <script type="text/javascript" src="javascript.js?v=<?php $version ?>"></script>
  </head>

  <body>
    <a href="index.php?v=<?php $version ?>">RITORNA ALLA PAGINA INIZIALE</a>

    <h4>Stored Procedure : fermate di un treno</h4>
    <p>A seconda della denominazione del treno scelto, questa procedura
    darà come risultato le possibili corse che il suddetto treno cercato farà : <br>
    Inserimento denominazione treno :
    <select id="selezione">
      <option value="Regionale_3444">Regionale 3444</option>
      <option value="Regionale_3562">Regionale 3562</option>
      <option value="Regionale_3985">Regionale 3985</option>
      <option value="Regionale_3564">Regionale 3564</option>
    </select>
    <button type="button" onclick="toggleEvent()">Trova corse</button></p>

    <div class="table_content">
      <?php
        for ($j=0; $j < 4; $j++) {
          switch ($j) {
            case "0": { $train_chosen = "Regionale_3444"; break; }
            case "1": { $train_chosen = "Regionale_3562"; break; }
            case "2": { $train_chosen = "Regionale_3985"; break; }
            case "3": { $train_chosen = "Regionale_3564"; break; }
          } ?>
        <div>
          <table id="<?php echo $train_chosen ?>" class="hidden">
            <tr>
              <?php
                $sql = "CALL fermate_treno(?)";
                $prepared = $connection->prepare($sql);
                $prepared->execute(array($train_chosen));

                if($prepared->rowCount() > 0){
                  $ris = $prepared->fetchAll();
                }
                for ($i=0; $i < $prepared->columnCount(); $i++) {
                  $col = $prepared->getColumnMeta($i); ?>
                  <th><?php echo $col["name"]; ?></th>
                <?php
              }
              ?>
            </tr>

            <?php
              foreach($ris as $row){ ?>
                <tr> <?php
                for ($i=0; $i < $prepared->columnCount(); $i++) {
                  $col = $prepared->getColumnMeta($i); ?>
                  <td> <?php echo $row[$col["name"]]; ?></td>
                <?php
                } ?>
                </tr>
              <?php
              }
            ?>
          </table>
        </div>
        <?php } ?>
    </div>

    <h4>Stored Procedure : numero posti di un treno</h4>
    <p>Stampa una tabella con il numero totale di posti disponibili all'interno di ogni treno
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $sql = "CALL num_posti_treni()";
              $prepared = $connection->prepare($sql);
              $prepared->execute();

              if($prepared->rowCount() > 0){
                $ris = $prepared->fetchAll();
              }
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <th><?php echo $col["name"]; ?></th>
              <?php
            }
            ?>
          </tr>

          <?php
            foreach($ris as $row){ ?>
              <tr> <?php
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <td> <?php echo $row[$col["name"]]; ?></td>
              <?php
              } ?>
              </tr>
            <?php
            }
          ?>
        </table>
      </div>
    </div>

    <h4>Stored Procedure : vendita biglietti mensile</h4>
    <p>Viene stampata una tabella con il numero di biglietti venduti raggruppati per giorno per il mese selezionato.<br>
    Siccome sono stati inseriti solo biglietti venduti nel mese di maggio (5), la Stored Procedure verra' <br>
    direttamente eseguita con il numero 5
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $sql = "CALL vendita_biglietti_mensile(?);";
              $mese = 5;
              $prepared = $connection->prepare($sql);
              $prepared->execute(array($mese));

              if($prepared->rowCount() > 0){
                $ris = $prepared->fetchAll();
              }
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <th><?php echo $col["name"]; ?></th>
              <?php
            }
            ?>
          </tr>

          <?php
            foreach($ris as $row){ ?>
              <tr> <?php
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <td> <?php echo $row[$col["name"]]; ?></td>
              <?php
              } ?>
              </tr>
            <?php
            }
          ?>
        </table>
      </div>
    </div>

    <h4>Stored Procedure : lista delle stazioni piu' trafficate</h4>
    <p>Viene stampata una tabella con la lista delle stazioni piu' trafficate. Per stazioni trafficate <br>
    si intende le stazioni dove arrivano piu' persone :
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $sql = "CALL lista_stazioni_trafficate();";
              $prepared = $connection->prepare($sql);
              $prepared->execute();

              if($prepared->rowCount() > 0){
                $ris = $prepared->fetchAll();
              }
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <th><?php echo $col["name"]; ?></th>
              <?php
            }
            ?>
          </tr>

          <?php
            foreach($ris as $row){ ?>
              <tr> <?php
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <td> <?php echo $row[$col["name"]]; ?></td>
              <?php
              } ?>
              </tr>
            <?php
            }
          ?>
        </table>
      </div>
    </div>

    <h4>Stored Procedure : trova treno</h4>
    <p>Per i dati immessi nelle tabelle e per semplificare tutto il processo di esposizione<br>
    si suppone che l'utente come stazione di partenza metta "Trieste Centrale" e invece come<br>
    stazione di arrivo metta "Stazione di Monfalcone e che l'orario sia 15:00 . Facendo ciò si otterrebbe il seguente risultato :"
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $id_staz_a = "llxa2";
              $id_staz_p = "9o55i";
              $time = "15:00";
              $sql = "CALL trova_treno(?, ?, ?);";
              $prepared = $connection->prepare($sql);
              $prepared->execute(array($id_staz_a, $id_staz_p, $time));

              if($prepared->rowCount() > 0){
                $ris = $prepared->fetchAll();
              }
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <th><?php echo $col["name"]; ?></th>
              <?php
            }
            ?>
          </tr>

          <?php
            foreach($ris as $row){ ?>
              <tr> <?php
              for ($i=0; $i < $prepared->columnCount(); $i++) {
                $col = $prepared->getColumnMeta($i); ?>
                <td> <?php echo $row[$col["name"]]; ?></td>
              <?php
              } ?>
              </tr>
            <?php
            }
          ?>
        </table>
      </div>
    </div>

    <h4>Stored Procedure : stampa riepilogo</h4>
    <p>Supponendo di voler avere il riepilogo del biglietto di Emma	Ferri per il suo viaggio <br>
    a S. Pietro In Casale si ottiene il seguente risultato :




    <?php
      }catch (PDOException $e){
        die("Errore di connessione al database".$e->getMessage());
      }
      $connection = null;
    ?>
  </body>
</html>
