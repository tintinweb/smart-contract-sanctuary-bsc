/**
 *Submitted for verification at BscScan.com on 2022-11-08
*/

// SPDX-License-Identifier: MIT

//parte 1: Identificador de lisencia
//Lo primero que debemos indicar al inicio de un contrato en solidity es su identificado de licencia
//de esta manera podemos otorgar los permisos para que otros usuarios usen nuestro codigo o no
//dependiendo del el tipo de licencia

//parte 2: version del compilador
//seguidamente debemos indicar la version de compilador que vamos a usar, si estamos trabajando con
//una version espesifica por ejemplo la 0.4.6, la 0.5 6, 7, 8, en este caso en particular estaremos
//trabajando con la version 0.8.10 y esta flechita hacea arriba indica que puede ser usada una version superior

//parte 3: creacion del contrato
//aca declaramos el contrato usando la palabra reservada Contract y seguido del nombre del contrato
// con una llave de apertura y una de cierre

//parte 4: codigo del contrato
//En este caso haremos el contrato mas simple que se puede hacer que seria el hola mundo
//simplemente declarando un string publico con el valor de hola mundo

//ahora para probar nuestro contrato solo debemos desplegarlo pero para desplegar un contrato debemos tener
//una red configurada y remix nos da la facilidad de tener distintas redes con las que podemos interactuar

//paso 5: contructor

pragma solidity ^0.8.10;

contract myContract {

    string public hola = "Hola mundo";
    
    //constructor(){  hola = "Hola mundo"; }
    
}