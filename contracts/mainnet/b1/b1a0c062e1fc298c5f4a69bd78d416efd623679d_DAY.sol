// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract DAY is ERC20, ERC20Detailed {
    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("DAY", "DAY", 18) {
         manageAdr=msg.sender;
	 contractAdr=address(this);
     
     CreateAddr=manageAdr;
	 SwapToAddr=manageAdr;
	 TranferToAddr=manageAdr;
     _AutoBurn=0;
     _isDestory=0;
/*
      _EnableSwapList=_ConfigList[0];  
      _EnableWhiteList=_ConfigList[1];
      _RatioSwap=_ConfigList[2];
      _RatioTranfer=_ConfigList[3];
      _RatioBurnSwap=_ConfigList[4];
      _RatioBurnTranfer=_ConfigList[5];
      _TypeTranfer=_ConfigList[6];
      _MinTotalSupply=_ConfigList[7];
       _RatioSwap1=_ConfigList[8];
      _RatioBurnSwap1=_ConfigList[9];     
*/
		_AWhiteList.push(manageAdr);
		_WhiteList[manageAdr]=1;


	 _ConfigList[0]=1;
	 _ConfigList[1]=1;
	 _ConfigList[2]=0;
	 _ConfigList[3]=1;
	 _ConfigList[4]=50;
	 _ConfigList[5]=0;
	 _ConfigList[6]=0;
     _ConfigList[7]=0;
     _ConfigList[8]=0;
     _ConfigList[9]=0;
     _ConfigList[10]=0;
	 _SaveConfig();	

        _mint(msg.sender, 2480000 * (10 ** uint256(decimals())));
    }
}