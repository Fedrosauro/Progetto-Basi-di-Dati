<?php
include 'config.php';
try{
    $connection = new PDO("mysql:host=$host;dbname=$db",$user,$password);
?>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Tabelle</title>
    <link rel="stylesheet" href="style.css?v=<?php $version ?>">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono&display=swap" rel="stylesheet">
    <script type="text/javascript" src="javascript.js?v=<?php $version ?>"></script>
  </head>

  <body>
    <div class="center">
    <a href="index.php?v=<?php $version ?>" class="redLink" >RITORNA ALLA PAGINA INIZIALE</a> <br><br>

    <p style="margin: auto;"><span class="orange">>> </span>Selezionare la tabella interessata<span class="orange"> <<</span></p> <br>
    <select id="selezione">
      <option value="acquisto_biglietto">acquisto_biglietto</option>
      <option value="associazione_biglietto_corsa">associazione_biglietto_corsa</option>
      <option value="biglietto">biglietto</option>
      <option value="cliente">cliente</option>
      <option value="composizione_treno">composizione_treno</option>
      <option value="corsa">corsa</option>
      <option value="stazione">stazione</option>
      <option value="tipologia">tipologia</option>
      <option value="tratta">tratta</option>
      <option value="treno">treno</option>
      <option value="vagone">vagone</option>
    </select>
    <button type="button" onclick="toggleEvent()">Mostra/Nascondi tabella</button>
  </div>
    <div class="table_content">
      <?php
        for ($j=0; $j < 11; $j++) {
          switch ($j) {
            case "0": { $table_chosen = "acquisto_biglietto"; break; }
            case "1": { $table_chosen = "associazione_biglietto_corsa"; break; }
            case "2": { $table_chosen = "biglietto"; break; }
            case "3": { $table_chosen = "cliente"; break; }
            case "4": { $table_chosen = "composizione_treno"; break; }
            case "5": { $table_chosen = "corsa"; break; }
            case "6": { $table_chosen = "stazione"; break; }
            case "7": { $table_chosen = "tipologia"; break; }
            case "8": { $table_chosen = "tratta"; break; }
            case "9": { $table_chosen = "treno"; break; }
            case "10": { $table_chosen = "vagone"; break; }
          } ?>
        <div>
          <table id="<?php echo $table_chosen ?>" class="hidden">
            <tr>
              <?php
                $sql = "SELECT * FROM $table_chosen";
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
        <?php }
          }catch (PDOException $e){
            die("Errore di connessione al database".$e->getMessage());
          }

          $connection = null;
        ?>
    </div>
  </body>
</html>
