Søk i enhetsregisteret

# Installasjon

```shell
$ git clone https://github.com/espen/brreg.git
$ cd brreg
$ brreg.rb -h
```

# I bruk

```shell
brreg [options]
-n, --orgnr ORGNR                Organisasjonsnummer
-q, --query QUERY                Firmanavn
-d, --domain DOMAIN              Domenenavn (kun .no)
-v, --version                    Versjon
```

# Eksempel

```shell
~ brreg -q "inspired as"
Søker etter 'inspired as'
...............
994502085 GET INSPIRED AS
992842318 INDIGO INSPIRED INITIATIVE STENSRUD
996617742 INSPIRED BY ADELINA GRENMAR
999205224 UNGDOMSBEDRIFTEN INSPIRED
990610924 INSPIRED AS
994317318 INSPIRED THINKING Wenche A Buchman
~ brreg -n 990610924
Viser oppføring for orgnr 990610924
...............
INSPIRED AS
Nustadsløyfa 41
3970 LANGESUND
c/o Espen Antonsen Sverdrups gate 26B
0559 OSLO
~ brreg -d makeplans.no
Viser oppføring for orgnr 990610924
...............
INSPIRED AS
Nustadsløyfa 41
3970 LANGESUND
c/o Espen Antonsen Sverdrups gate 26B
0559 OSLO

Basert på Whois fra domenet makeplans.no
```