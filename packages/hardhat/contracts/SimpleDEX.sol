// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/*Implementar un exchange descentralizado simple que intercambie dos tokens ERC-20.*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface InterfaceTk {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}


contract SimpleDEX is Ownable(msg.sender) {
    InterfaceTk public tokenA;
    InterfaceTk public tokenB;

    constructor(address _tokenA, address _tokenB){
        require(_tokenA != address(0) && _tokenB != address(0), "Debe ingresar un token");
        tokenA = InterfaceTk(_tokenA);
        tokenB = InterfaceTk(_tokenB);

     }

    event AddedLiquidity(address indexed owner, uint256 amountA, uint256 amountB);
    event Swapped(address indexed trader, address tokenIn, uint256 amountIn, address tokenOut, uint256 amountOut);
    event Removed(address indexed owner, uint256 amountA, uint256 amountB);

      
    /*Añadir liquidez: El owner puede depositar pares de tokens en el pool 
    para proporcionar liquidez. Solo el owner tinen permisos para ingresar liquidez*/

    function addLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        require(amountA > 0 && amountB > 0, " Debe ingresar ambos montos.");
        /* uint256 _balanceA = tokenA.balanceOf(address(this));
        uint256 _balanceB = tokenB.balanceOf(address(this));
        if ( _balanceA != 0 && _balanceB != 0 ){
           uint256 _amountSuggest = (amountA * getPrice(address(tokenA))) / 1e18;
           //se da un pequeño marggen
           require(amountB >= _amountSuggest - 1 && amountB <= _amountSuggest + 1, "Tokens no proporcionales al precio actual");
        }*/
              
        address _senderFrom = msg.sender;
        address _contractTo = address(this);
        /*Previamente del Contrato TokenA y B se aprueba un monto de transferencia sobre el address del contrato SimpleDEX*/
        uint256 allowanceA = tokenA.allowance(_senderFrom, _contractTo);
        require(allowanceA >= amountA, "Supera al monto autorizado");
        uint256 allowanceB = tokenB.allowance(_senderFrom, _contractTo);
        require(allowanceB >= amountB, "Supera al monto autorizado");
        tokenA.transferFrom(_senderFrom, _contractTo, amountA); /*Transferencia Monto token A*/
        tokenB.transferFrom(_senderFrom, _contractTo, amountB); /*Transferencia Monto token B*/

        /*se genera Logs de la transacción*/
        emit AddedLiquidity(_senderFrom, amountA, amountB);
    }

    /*•	Intercambiar tokens: Los usuarios pueden intercambiar uno de los tokens por el otro utilizando el pool de liquidez.*/
    /*Función Intercambio TokenA por TokenB */
    function swapAforB(uint256 amountAIn) external {
        require(amountAIn > 0, "Debe ingresar un monto valido");
        
        address _sender = msg.sender;
        address _contractTo= address(this);
        uint256 _balanceA = tokenA.balanceOf(address(this));
        uint256 _balanceB = tokenB.balanceOf(address(this));
        require(amountAIn <=  _balanceA, "el monto de entrada debe ser menor e igual al del pool");
        /*Sale token A e ingresa token B
          (x+dx)(y-dy) = xy
          amountBOut (dy): Monto token salida
          amountAIn (dx): tokens que se intercambia.
          balanceA (x): Reservas actuales del token que el usuario está proporcionando.
          balanceB (y): Reservas actuales del token que el usuario recibirá.*/
          
        uint256 amountBOut = _balanceB - (_balanceA * _balanceB)/(_balanceA + amountAIn);
        //uint256 amountBOut = (amountAIn * balanceB) / (balanceA + amountAIn);
        uint256 allowanceA = tokenA.allowance(_sender, _contractTo);
        require(allowanceA >= amountAIn, "Supera al monto autorizado");
        tokenA.transferFrom(_sender, _contractTo, amountAIn); //tomar tokens del usuario que está realizando el intercambio y se transfiere al contrato
        tokenB.transfer(_sender, amountBOut);// transfiero al usuario el monto calculado por el intercambio

        emit Swapped(_sender, address(tokenA), amountAIn, address(tokenB), amountBOut);
    }

    /*Función Intercambio TokenB por TokenA */

    function swapBforA(uint256 amountBIn) external {
        require(amountBIn > 0, "Debe ingresar un monto valido");
        address _sender = msg.sender;
        address _contractTo = address(this);
        uint256 _balanceA = tokenA.balanceOf(address(this));
        uint256 _balanceB = tokenB.balanceOf(address(this));
        require(amountBIn <=  _balanceB, "el monto de entrada debe ser menor e igual al del pool");
        /*Sale token B e ingresa token A
          (x+dx)(y-dy) = xy
          amountAOut (dx): Monto token salida
          amountBIn (dy): tokens que se intercambia.
          balanceA (x): Reservas actuales del token que el usuario está proporcionando.
          balanceB (y): Reservas actuales del token que el usuario recibirá.*/
        uint256 amountAOut = (_balanceA * _balanceB) / (_balanceB-amountBIn) - _balanceA;
        //uint256 amountAOut = (amountBIn * balanceA) / (balanceB + amountBIn);
        uint256 allowanceB = tokenB.allowance(_sender, _contractTo);
        require(allowanceB >= amountBIn, "Supera al monto autorizado");
        tokenB.transferFrom(_sender, _contractTo, amountBIn); ////tomar tokens del usuario que está realizando el intercambio y se transfiere al contrato
        tokenA.transfer(_sender, amountAOut); // transfiero al usuario el monto calculado por el intercambio

        emit Swapped(_sender, address(tokenB), amountBIn, address(tokenA), amountAOut);
    }

   /*Retirar liquidez: El owner puede retirar sus participaciones en el pool.*/
    function removeLiquidity(uint256 amountA, uint256 amountB) external onlyOwner {
        uint256 _balanceA = tokenA.balanceOf(address(this));
        uint256 _balanceB = tokenB.balanceOf(address(this));

        require(amountA <= _balanceA && amountB <= _balanceB, "El monto a retirar supera al balance");
        address _sender = msg.sender;
        tokenA.transfer(_sender, amountA);
        tokenB.transfer(_sender, amountB);

        emit Removed(_sender, amountA, amountB);
    }

 /*Funcion getPrice: Consulta calculo de precio*/
    function getPrice(address _token) public view returns (uint256) {
        require(_token == address(tokenA) || _token == address(tokenB), "Token invalido");
        //require((tokenA.balanceOf(address(this)) > 0 && tokenB.balanceOf(address(this)) > 0), "Pool Vacio");

        if (_token == address(tokenA)) {
            return (tokenB.balanceOf(address(this))*10**18)/ tokenA.balanceOf(address(this)); //Precio de Token A
        } else {
            return (tokenA.balanceOf(address(this))*10**18)/ tokenB.balanceOf(address(this)); //Precio de Token B
        } 
    }
 
  
}

