<?php
require_once 'config.php';
try{
    $connection = new PDO("mysql:host=$host;dbname=$db",$user,$password);
    echo "Connessione al MySQL tramite PDO effettuata"."<br><br>";
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

    <h4>Stored Procedure : fermate di un treno <br></h4>
    <p>A seconda della denominazione del treno scelto, questa procedura
    darà come risultato le possibili corse che il suddetto treno cercato farà : <br>
    Inserimento denominazione treno :
    <select id="selezione">
      <option value="Regionale_3444">Regionale 3444</option>
      <option value="Regionale_3562">Regionale 3562</option>
      <option value="Regionale_3985">Regionale 3985</option>
      <option value="Regionale_3564">Regionale 3564</option>
    </select>
    <button type="button" id="button" onclick="toggleEvent()">Trova corse</button>

    <?php
      for ($j=0; $j < 4; $j++) {
        switch ($j) {
          case "0": { $train_chosen = "Regionale_3444"; break; }
          case "1": { $train_chosen = "Regionale_3562"; break; }
          case "2": { $train_chosen = "Regionale_3985"; break; }
          case "3": { $train_chosen = "Regionale_3564"; break; }
        } ?>
      <div class="table_content">
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
      <?php }
        }catch (PDOException $e){
          die("Errore di connessione al database".$e->getMessage());
        }

        $connection = null;
      ?>
  </div>
  </body>
</html>
