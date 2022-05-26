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
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet">
    <script type="text/javascript" src="javascript.js?v=<?php $version ?>"></script>
  </head>

  <body>
    <div class="center">
      <a href="index.php?v=<?php $version ?>" class="redLink">RITORNA ALLA PAGINA INIZIALE</a>
    </div>

    <h4>Stored Procedure : fermate di un treno</h4>
    <p><span class="orange">>> </span>A seconda della denominazione del treno scelto, questa procedura
    darà come risultato le possibili corse che il suddetto treno cercato farà
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
                $sql = "SELECT CONCAT(nome_stazione, ' (', SUBSTRING(ora_a, 1, 5), ')') as
                Stazione_Arrivo_Ora
                FROM corsa c INNER JOIN stazione s on c.id_stazione_a = s.id_stazione
                WHERE id_treno = (SELECT id_treno FROM treno WHERE denominazione = ?)
                ORDER BY ora_a";
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
    <p><span class="orange">>> </span>Stampa una tabella con il numero totale di posti disponibili all'interno di ogni treno
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $sql = "SELECT denominazione, t.id_treno, SUM(num_posti) AS posti_Totali FROM treno t
              INNER JOIN composizione_treno ct on t.id_treno = ct.id_treno
              INNER JOIN vagone v on ct.id_vagone = v.id_vagone
              INNER JOIN tipologia tp on v.tipo = tp.tipo
              GROUP BY t.id_treno ORDER BY posti_Totali";
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
    <p><span class="orange">>> </span>Viene stampata una tabella con il numero di biglietti venduti raggruppati per giorno per il mese selezionato.
    Siccome sono stati inseriti solo biglietti venduti nel mese di maggio (5), la Stored Procedure verra'
    direttamente eseguita con il numero 5
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $sql = "SELECT data_acquisto AS giorno, COUNT(*) AS num_Biglietti FROM acquisto_biglietto
              WHERE MONTH(data_acquisto) = ?
              GROUP BY data_acquisto ORDER BY data_acquisto";
              $mese = "5";
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
    <p><span class="orange">>> </span>Viene stampata una tabella con la lista delle stazioni piu' trafficate. Per stazioni trafficate
    si intende le stazioni dove arrivano piu' persone :
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $sql = "SELECT nome_stazione, COUNT(*) as traffico_persone FROM acquisto_biglietto
              INNER JOIN biglietto USING (id_biglietto)INNER JOIN associazione_biglietto_corsa USING (id_biglietto)
              INNER JOIN corsa USING (id_corsa)
              INNER JOIN stazione s on (corsa.id_stazione_a = s.id_stazione)
              GROUP BY id_stazione_a ORDER BY traffico_persone DESC";
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
    <p><span class="orange">>> </span>Per i dati immessi nelle tabelle e per semplificare tutto il processo di esposizione
    si suppone che l'utente come stazione di partenza metta "Trieste Centrale" e invece come
    stazione di arrivo metta "Stazione di Monfalcone e che l'orario sia 15:00 . Facendo ciò si otterrebbe il seguente risultato :"
    <div class="table_content">
      <div>
        <table>
          <tr>
            <?php
              $id_staz_a = "llxa2";
              $id_staz_p = "9o55i";
              $time = "15:00";
              $sql = "SELECT denominazione AS treno, SUBSTRING(c.ora_p, 1, 5) AS ora_partenza,
              SUBSTRING(c.ora_a, 1, 5) AS ora_arrivo FROM corsa c
              INNER JOIN treno t on c.id_treno = t.id_treno
              WHERE id_stazione_a = ? AND id_stazione_p = ? AND ora_p > ?
              ORDER BY c.ora_p";
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
    <p><span class="orange">>> </span>Purtroppo questa procedura per motivi a me adesso ignoti non sono riuscito a farla
      funzionare. In ogni caso l'output della procedura per stampare per esempio il riepilogo
      biglietto comprato da Emma Ferri sarebbe stato:</p>

      <p class="color_back">Emma Ferri. Costo biglietto : 23.45 euro. Data Viaggio :2022-05-22  |
      Regionale 3562, Trieste Centrale -> 15:16, Venezia Mestre -> 17:11 |
      Regionale 3985, Venezia Mestre -> 17:53, S. Pietro In Casale -> 19:30</p>

    <?php
      }catch (PDOException $e){
        die("Errore di connessione al database".$e->getMessage());
      }
      $connection = null;
    ?>
  </body>
</html>
