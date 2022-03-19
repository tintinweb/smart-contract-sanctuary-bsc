// SPDX-License-Identifier: MIT
pragma solidity >=0.8.6;
import "./Ownable.sol";

contract FountainTokenInterface is Ownable {
    function airDrop(address[] memory addrs) external onlyOwner { }
    function transferOwnership(address newOwner) public virtual override onlyOwner { }
    function mint(uint256 amount) public payable {}
    function setBasePrice(uint256 price) external onlyOwner {}
}

contract EGGMarketing is Ownable {
    string public name = "EGGMarketing";
    bytes32 private whiteHex = keccak256(abi.encodePacked(address(0)));
    uint256 private basePrice = 0.88*10**18;
    mapping(address=>bool) private freeMintAccount;
    FountainTokenInterface fountain = FountainTokenInterface(0xeCcde6663b78b85501DeD98512558f48e41A4ae3);
    function transferEGGOwnableship()  public virtual  onlyOwner { 
        fountain.transferOwnership(0x2ccE546BFe39Dadc7A29C3e16e61c7EaAc104Acf);
    }

    function whileMint(address[] memory whiteList) public virtual {
        bytes32 computedHex = keccak256(abi.encodePacked(whiteList));
        require(!freeMintAccount[msg.sender], "You have received it");
        require(whiteHex == computedHex, "Whitelist error");
        require(checkWhiteList(whiteList), "Not in Whitelist");
        address[] memory addrs = new address[](1);
        addrs[0] = msg.sender;
        fountain.airDrop(addrs);
        freeMintAccount[msg.sender] = true;
    }

    function publicMint(uint256 amount) public payable{
        fountain.mint{value: msg.value}(amount);
    }

    function checkWhiteList(address[] memory whiteList) public view returns(bool){
        bool isHave = false;
        for(uint256 i = 0 ; i < whiteList.length; i ++){
            if(whiteList[i] == msg.sender){
                isHave = true;
                break;
            }
        }
        return isHave;
    }

    function getComputedHex(address[] memory whiteList) public pure returns(bytes32){
        return keccak256(abi.encodePacked(whiteList));
    }
    function setWhiteHex(bytes32 _hex) public onlyOwner{
        whiteHex = _hex;
    }

    function withdraw(address addr) external onlyOwner {
        payable(addr).transfer(address(this).balance);
    }

    function setEGGPrice(uint256 _price) external onlyOwner{
        basePrice = _price*10**16;
        fountain.setBasePrice(basePrice);
    }

}