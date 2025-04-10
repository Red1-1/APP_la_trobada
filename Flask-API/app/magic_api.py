from mtgsdk import Card
from routes import databaseconnection
import mysql.connector
from time import sleep
import time
from datetime import timedelta

def insert_cards_batch(batch):
    cnx = None
    try:
        cnx = databaseconnection()
        if cnx and cnx.is_connected():
            with cnx.cursor(dictionary=True) as cursor:
                cont = 0
                # Preparamos los datos asegurando que todos los campos sean strings
                for card in batch:
                    if card.multiverse_id is not None:
                        carta = card.multiverse_id
                        print(f"\nInsertando carta: {card.name}")
                        print(type(carta))
                        cont += 1
                # Insertamos el lote
                        cursor.execute("INSERT INTO cartes(id_carta) VALUES (%s)", 
                             (carta, ))
                        cnx.commit()
                        # Devolvemos el número de cartas insertadas
                return cont
    except mysql.connector.Error as err:
        print(f"\nError en el batch: {err}")
        print(f"Última carta procesada: {batch[-1].name if batch else 'N/A'}")
        return 0
    finally:
        if cnx and cnx.is_connected():
            cnx.close()

def process_all_cards():
    batch_size = 500  # Reducido para manejar mejor los errores
    current_batch = []
    total_inserted = 0
    start_time = time.time()
    
    try:
        print("Iniciando proceso de carga de cartas...")
        print(f"Hora de inicio: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Obtenemos el iterador de cartas
        all_cards = Card.all()
        
        for i, card in enumerate(all_cards, 1):
            try:
                if card.multiverse_id is not None:
                    current_batch.append(card)
                    
                    # Procesamos el lote cuando alcanza el tamaño
                    if len(current_batch) >= batch_size:
                        inserted = insert_cards_batch(current_batch)
                        total_inserted += inserted
                        current_batch = []
                        
                        # Mostramos progreso
                        elapsed = time.time() - start_time
                        avg_speed = total_inserted / elapsed if elapsed > 0 else 0
                        print(f"\nProgreso: {total_inserted} cartas insertadas | "
                              f"Tiempo: {timedelta(seconds=int(elapsed))} | "
                              f"Velocidad: {avg_speed:.2f} cartas/segundo")
                        
                        # Pausa para evitar sobrecarga
                        sleep(1.5)  # Aumentado el tiempo de pausa
            
                # Mostrar progreso cada 100 cartas
                if i % 100 == 0:
                    elapsed = time.time() - start_time
                    print(f"\rCartas procesadas: {i} | Tiempo: {timedelta(seconds=int(elapsed))}", end='', flush=True)
            
            except Exception as card_error:
                print(f"\nError procesando carta {i}: {card_error}")
                continue
        
        # Procesar el último lote incompleto
        if current_batch:
            inserted = insert_cards_batch(current_batch)
            total_inserted += inserted
        
    except Exception as e:
        print(f"\nError general: {e}")
    finally:
        end_time = time.time()
        total_time = end_time - start_time
        print("\n" + "="*50)
        print("PROCESO COMPLETADO")
        print(f"Hora de finalización: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"Tiempo total: {timedelta(seconds=int(total_time))}")
        print(f"Cartas insertadas: {total_inserted}")
        if total_inserted > 0:
            print(f"Velocidad promedio: {total_inserted/total_time:.2f} cartas/segundo")
        print("="*50)

if __name__ == "__main__":
    process_all_cards()
    
    
    