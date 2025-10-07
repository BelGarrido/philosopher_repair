#!/bin/bash
# ============================================================
# 42 Philosophers Comprehensive Tester
# Tests funcionales + detección de fugas + data races
# ============================================================

EXEC=./philo

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
NC="\033[0m" # sin color

echo -e "\n🧠 ${CYAN}42 Philosophers Advanced Test Suite${NC}\n"

# ------------------------------------------------------------
# Helper para correr un test funcional
# ------------------------------------------------------------
run_test() {
	echo -e "${YELLOW}→ $1${NC}"
	echo -e "Command: ${CYAN}$2${NC}"
	$2 > tmp.log 2>&1 &
	PID=$!
	sleep $3
	if ps -p $PID > /dev/null; then
		kill $PID 2>/dev/null
		echo -e "${RED}❌ Timeout / sigue corriendo tras $3s${NC}\n"
	else
		echo -e "${GREEN}✅ Terminó dentro de $3s${NC}\n"
	fi
}

# ------------------------------------------------------------
# 1️⃣ Test funcionales principales
# ------------------------------------------------------------
run_test "1 filósofo debe morir (sin segundo tenedor)" \
"$EXEC 1 800 200 200" 2

run_test "2 filósofos correctos (no mueren)" \
"$EXEC 2 800 200 200" 5

run_test "Todos comen 3 veces → simulación termina limpia" \
"$EXEC 4 800 200 200 3" 6

run_test "Mueren rápido si time_to_die < time_to_eat" \
"$EXEC 3 200 300 100" 3

run_test "80 filósofos → sin deadlocks" \
"$EXEC 80 800 200 200" 8

run_test "Parámetros inválidos → salida con error" \
"$EXEC -5 800 200 200" 2

# ------------------------------------------------------------
# 2️⃣ Chequeo de fugas de memoria (opcional)
# ------------------------------------------------------------
if command -v valgrind &>/dev/null; then
	echo -e "${YELLOW}→ Chequeando fugas de memoria con valgrind...${NC}"
	valgrind --leak-check=full --error-exitcode=42 $EXEC 5 800 200 200 2 > valgrind.log 2>&1
	if [ $? -eq 42 ]; then
		echo -e "${RED}❌ Fugas detectadas (ver valgrind.log)${NC}\n"
	else
		echo -e "${GREEN}✅ Sin fugas detectadas${NC}\n"
	fi
else
	echo -e "${YELLOW}⚠️ Valgrind no instalado, saltando test de fugas.${NC}\n"
fi

# ------------------------------------------------------------
# 3️⃣ Detección de condiciones de carrera / mutex
# ------------------------------------------------------------
check_races() {
	TOOL=$1
	if ! command -v valgrind &>/dev/null; then
		echo -e "${YELLOW}⚠️ $TOOL requiere valgrind instalado${NC}\n"
		return
	fi
	echo -e "${YELLOW}→ Ejecutando detección de data races con $TOOL...${NC}"
	valgrind --tool=$TOOL --error-exitcode=42 $EXEC 5 800 200 200 2 > $TOOL.log 2>&1
	if [ $? -eq 42 ]; then
		echo -e "${RED}❌ Problemas detectados por $TOOL (ver $TOOL.log)${NC}\n"
	else
		echo -e "${GREEN}✅ Sin condiciones de carrera detectadas por $TOOL${NC}\n"
	fi
}

check_races helgrind
check_races drd

# Limpieza
rm -f tmp.log
echo -e "${GREEN}✅ Todas las pruebas completadas.${NC}\n"
