//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./IERC20Metadata.sol";

import "./ILock.sol";

interface IPancakePair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}
contract Lock is ILock {
  address[] public override liquidities;
  address[] public override tokens;

  mapping(address=>TokenList[]) public liquidityList;
  mapping(address=>TokenList[]) public tokenList;
  function add(address _token, uint256 _endDateTime, uint256 _amount, address _owner, bool _isLiquidity) external override{
    require(_amount>0, "zero amount!");
    require(_token!=address(0x0),"token!");
    require(_owner!=address(0x0),"owner!");
    if(_isLiquidity){      
      require(_endDateTime>=block.timestamp+1 days,"duration!");
      address token0=IPancakePair(_token).token0();
      address token1=IPancakePair(_token).token1();
      require(token0!=address(0x0) && token1!=address(0x0), "not a liquidity");
      IPancakePair(_token).transferFrom(msg.sender, address(this), _amount);
      if(liquidityList[_token].length==0){
        liquidities.push(_token);
        liquidityList[_token].push(TokenList({
            amount:_amount,
            startDateTime:block.timestamp,
            endDateTime:_endDateTime,
            owner:_owner,
            creator:msg.sender
          }));
        
        
      }else{
        bool isExisted=false;
        for(uint i=0;i<liquidityList[_token].length;i++){
          if(liquidityList[_token][i].endDateTime==_endDateTime){
            if(liquidityList[_token][i].amount==0){
              liquidityList[_token][i].startDateTime=block.timestamp;
            }
            liquidityList[_token][i].amount=liquidityList[_token][i].amount+_amount;
            isExisted=true;
            break;
          }
        }
        if(!isExisted){
          liquidityList[_token].push(TokenList({
            amount:_amount,
            startDateTime:block.timestamp,
            endDateTime:_endDateTime,
            owner:liquidityList[_token][0].owner!=address(0x0) ? liquidityList[_token][0].owner : _owner,
            creator:msg.sender
          }));
        } 
      }
      string memory token0Name=IERC20Metadata(token0).name();
      string memory token1Name=IERC20Metadata(token1).name();
      string memory token0Symbol=IERC20Metadata(token0).symbol();
      string memory token1Symbol=IERC20Metadata(token1).symbol();
      emit LiquidityLockAdded(_token, _amount, _owner, token0Name, token1Name, token0Symbol, token1Symbol);    
    }else{
      require(_endDateTime>=block.timestamp+1 days,"duration!");
      IERC20Metadata(_token).transferFrom(msg.sender, address(this), _amount);
      if(tokenList[_token].length==0){
        tokens.push(_token);
        tokenList[_token].push(TokenList({
            amount:_amount,
            startDateTime:block.timestamp,
            endDateTime:_endDateTime,
            owner:_owner,
            creator:msg.sender
          }));     
      }else{
        bool isExisted=false;
        for(uint i=0;i<tokenList[_token].length;i++){
          if(tokenList[_token][i].endDateTime==_endDateTime){
            if(tokenList[_token][i].amount==0){
              tokenList[_token][i].startDateTime=block.timestamp;
            }
            tokenList[_token][i].amount=tokenList[_token][i].amount+_amount;
            isExisted=true;
            break;
          }
        }
        if(!isExisted){
          tokenList[_token].push(TokenList({
            amount:_amount,
            startDateTime:block.timestamp,
            endDateTime:_endDateTime,
            owner:tokenList[_token][0].owner!=address(0x0) ? tokenList[_token][0].owner : _owner,
            creator:msg.sender
          }));
        }   
      }
      string memory name=IERC20Metadata(_token).name();
      string memory symbol=IERC20Metadata(_token).symbol();
      uint8 decimals=IERC20Metadata(_token).decimals();
      emit TokenLockAdded(_token, _amount, _owner, name, symbol, decimals);
    }
    
  }
  function unlockLiquidity(address _token) external override returns (bool){
    bool isExisted=false;
    uint256 _amount;
    for(uint i=0;i<liquidityList[_token].length;i++){
      if(liquidityList[_token][i].owner==msg.sender && liquidityList[_token][i].endDateTime<block.timestamp && liquidityList[_token][i].amount>0){
        isExisted=true;
        _amount=_amount+liquidityList[_token][i].amount;
        liquidityList[_token][i].amount=0;
      }
    }
    require(isExisted==true, "no existed");
    IPancakePair(_token).transfer(msg.sender, _amount);      
    for(uint i=0;i<liquidityList[_token].length;i++){
      if(liquidityList[_token][i].amount==0){
        liquidityList[_token][i]=liquidityList[_token][liquidityList[_token].length-1];
        liquidityList[_token].pop();
      }
    }
    if(liquidityList[_token].length==0){
      for(uint i=0;i<liquidities.length;i++){
        if(liquidities[i]==_token){
          liquidities[i]=liquidities[liquidities.length-1];
          liquidities.pop();
          break;
        }
      }
      
    }    
    emit UnlockLiquidity(_token, _amount);
    return isExisted;
  }
  function unlockToken(address _token) external override returns (bool){
    bool isExisted=false;
    uint256 _amount;
    for(uint i=0;i<tokenList[_token].length;i++){
      if(tokenList[_token][i].owner==msg.sender && tokenList[_token][i].endDateTime<block.timestamp && tokenList[_token][i].amount>0){
        isExisted=true;
        _amount=_amount+tokenList[_token][i].amount;
        tokenList[_token][i].amount=0;
      }
    }
    require(isExisted==true, "no existed");
    IERC20Metadata(_token).transfer(msg.sender, _amount);    
    for(uint i=0;i<tokenList[_token].length;i++){
      if(tokenList[_token][i].amount==0){
        tokenList[_token][i]=tokenList[_token][tokenList[_token].length-1];
        tokenList[_token].pop();
      }
    }
    if(tokenList[_token].length==0){
      for(uint i=0;i<tokens.length;i++){
        if(tokens[i]==_token){
          tokens[i]=tokens[tokens.length-1];
          tokens.pop();
          break;
        }
      }
    }
    emit UnlockToken(_token, _amount);
    return isExisted;
  }

  function extendLock(address _token, uint256 _endDateTime, bool _isLiquidity, uint256 _updateEndDateTime)external override{
    require(_endDateTime<_updateEndDateTime, "wrong timer");
    bool isExisted=false;
    if(_isLiquidity){
      for(uint i=0;i<liquidityList[_token].length;i++){
        if(liquidityList[_token][i].owner==msg.sender && liquidityList[_token][i].endDateTime==_endDateTime && liquidityList[_token][i].amount>0){
          isExisted=true;
          liquidityList[_token][i].endDateTime=_updateEndDateTime;
        }
      }
    }else{
      for(uint i=0;i<tokenList[_token].length;i++){
        if(tokenList[_token][i].owner==msg.sender && tokenList[_token][i].endDateTime==_endDateTime && tokenList[_token][i].amount>0){
          isExisted=true;          
          tokenList[_token][i].endDateTime=_updateEndDateTime;          
        }
      }
    }
    require(isExisted, "No lock");
    emit LockExtended(_token, _endDateTime, _isLiquidity, _updateEndDateTime);
  }
  function getLiquidityAddresses() public view returns(address[] memory){
    return liquidities;
  }
  function getTokenAddresses() public view returns(address[] memory){
    return tokens;
  }
  function getTokenDetails(address token) public view returns(TokenList[] memory){
    return tokenList[token];
  }
  function getLiquidityDetails(address token) public view returns(TokenList[] memory){
    return liquidityList[token];
  }
}