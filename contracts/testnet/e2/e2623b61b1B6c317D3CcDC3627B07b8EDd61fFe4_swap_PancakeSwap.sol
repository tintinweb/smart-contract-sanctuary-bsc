/**
 *Submitted for verification at BscScan.com on 2022-03-22
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//Hecho por Angelica De Leon
//importa interface ERC20

interface IERC20 {
  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

//importa el router v2
//en este contrato se llamará a la función swapExactTokensForTokens
//por tal razón también necesitaré obtener el monto mínimo de conversión llamando a la función getAmountsOut.

interface IPancakeRouter02 {
  function getAmountsOut(uint256 amountIn, address[] memory path)
    external
    view
    returns (uint256[] memory amounts);

  function WETH() external pure returns (address);

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);

  function swapExactETHForTokens(
            uint256 amountOutMin,
            address[] calldata path,
            address to,
            uint256 deadline
        ) external payable returns (uint256[] memory amounts);
}

contract swap_PancakeSwap {
  //address del routerv2 de pancakeswap
  address private constant UNISWAP_V2_ROUTER =
    0xD99D1c33F9fC3444f8101754aBC46c52416550D1;

  //obtiene el address del WETH
  address WETH = IPancakeRouter02(UNISWAP_V2_ROUTER).WETH();

  //La función que hace el swap para convertir un token en otro.
  //token in = el token que se va a tradear
  //token out = el token que se quiere recibir
  //amount in = el monto que se va a enviar
  //amountoutMin = en monto minimo que se acepta en la transaccion
  //to = el address al que se enviarán los tokens convertidos
  function swap_ETH_x_token(    
    address _tokenOut,
    uint256 _amountOutMin,
    address _to) external payable {

    //Se tranfieren el monto del swap a este contrado.
    IERC20(WETH).transferFrom(msg.sender, address(this),  msg.value);

    //después se permite que el enrutados V2 de pancakeswap gaste el token que se acaba de depositar.
    IERC20(WETH).approve(UNISWAP_V2_ROUTER,  msg.value);

    address[] memory path;
      path[0] = WETH;
      path[1] = _tokenOut;

    IPancakeRouter02(UNISWAP_V2_ROUTER).swapExactETHForTokens{value: msg.value}(
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
  }

  function swap_token_x_token(
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn,
    uint256 _amountOutMin,
    address _to
  ) external {
    //Se tranfieren el monto del swap a este contrado.
    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

    //después se permite que el enrutados V2 de pancakeswap gaste el token que se acaba de depositar.
    IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

    //se crea la variable path, el cual es un array de los address.
    //el path almacenará 3 addresses [tokenIn, WETH, tokenOut]
    // y validará si el address enviado es igual al WETH
    address[] memory path;
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }
    //aqui se llama a la function swapExactTokensForTokens
    //y el deadline será enviado como block.timestamp (tiempo de espera)
    IPancakeRouter02(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
      _amountIn,
      _amountOutMin,
      path,
      _to,
      block.timestamp
    );
  }

  //esta función retorna will el monto minimo para realizar el swap
  function getAmountOutMin(
    address _tokenIn,
    address _tokenOut,
    uint256 _amountIn
  ) external view returns (uint256) {
    //Lo mismo que en la función anterior:
    //se crea la variable path, el cual es un array de los address.
    //el path almacenará 3 address [tokenIn, WETH, tokenOut]
    // y validará si el address enviado es igual al WETH
    address[] memory path;
    if (_tokenIn == WETH || _tokenOut == WETH) {
      path = new address[](2);
      path[0] = _tokenIn;
      path[1] = _tokenOut;
    } else {
      path = new address[](3);
      path[0] = _tokenIn;
      path[1] = WETH;
      path[2] = _tokenOut;
    }

    uint256[] memory amountOutMins = IPancakeRouter02(UNISWAP_V2_ROUTER)
      .getAmountsOut(_amountIn, path);
    return amountOutMins[path.length - 1];
  }
}