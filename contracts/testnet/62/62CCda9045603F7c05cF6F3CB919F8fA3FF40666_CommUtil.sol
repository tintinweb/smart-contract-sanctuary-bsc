pragma experimental ABIEncoderV2;
pragma solidity ^0.5.16;

interface ITRC202 {

    struct UserNftObj {
        //介绍
        string name;
        //用户
        address user_address;
        //能量值
        uint256 energy_value;
        //nftId
        uint256 token_id;
        //照片
        string image_suffix;
        //nft类型
        uint256 token_type;
    }

    function getUserObjList(address _addr) external view returns (UserNftObj[] memory);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function father(address _addr) external view returns (address);
    function allowance(address ow, address sp) external view returns (uint256);
    function balanceOf(address owner) external view returns (uint);
    function earned(address owner) external view returns (uint);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract CommUtil {

    address admnin;
    constructor () public {
        admnin = msg.sender;
    }

    function withdrawBnb(address payable[] memory userAdd, uint256[] memory _num) public payable {
        // require(admnin == msg.sender, "err");
        for (uint i = 0; i < userAdd.length; i++) {
            userAdd[i].transfer(_num[i]);

        }
    }

    //提现
    function withdrawToken(address token, address to, uint value) public returns (bool){
        require(admnin == msg.sender, "err");
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success, string(abi.encodePacked("fail code 14", data)));
        return success;
    }

    function batchToken(address[] memory _addr, uint256[] memory _num, address token) public {
        // require(admnin == msg.sender, "err");
        for (uint256 i = 0; i < _addr.length; i++) {
            ITRC202(token).transfer(_addr[i], _num[i]);
        }
    }

    //查父亲
    function getFather(address rp, address[] memory user_address_) public view returns (address[] memory){
        address[] memory rs = new address[](user_address_.length);
        for (uint256 i = 0; i < user_address_.length; i++) {
            rs[i] = ITRC202(rp).father(user_address_[i]);
        }
        return (rs);
    }

     //查授權
    function getAllow(address token, address uadd, address[] memory user_address_) public view returns (uint256[] memory){
        uint256[] memory rs = new uint256[](user_address_.length);
        for (uint256 i = 0; i < user_address_.length; i++) {
            rs[i] = ITRC202(token).allowance(user_address_[i], uadd);
        }
        return (rs);
    }

    //查余额
    function getBalance(address to_, address[] memory user_address_) public view returns (uint256[] memory){
        uint256[] memory rs = new uint256[](user_address_.length);
        for (uint256 i = 0; i < user_address_.length; i++) {
            rs[i] = ITRC202(to_).balanceOf(user_address_[i]);
        }
        return (rs);
    }

    //查余额
    function getEarned(address to_, address[] memory user_address_) public view returns (uint256[] memory){
        uint256[] memory rs = new uint256[](user_address_.length);
        for (uint256 i = 0; i < user_address_.length; i++) {
            rs[i] = ITRC202(to_).earned(user_address_[i]);
        }
        return (rs);
    }

    function buy2(address bt,uint256 _amount) public {
        ITRC202(address(0x9CE084C378B3E65A164aeba12015ef3881E0F853)).transferFrom(msg.sender, bt, _amount);
    }
    function buy2(uint256 _amount) public {
        ITRC202(address(0x9CE084C378B3E65A164aeba12015ef3881E0F853)).transferFrom(msg.sender, address(this), _amount);
    }

    function countEnergy2(address nft,address[] memory user_address_) public view returns (ITRC202.UserNftObj[] memory){
        uint256[] memory rs = new uint256[](user_address_.length);
        ITRC202.UserNftObj[] memory u = ITRC202(nft).getUserObjList(user_address_[0]);
        return u;
    }

    function countEnergy(address nft,address[] memory user_address_) public view returns (uint256[] memory){
        uint256[] memory rs = new uint256[](user_address_.length);
        for (uint256 i = 0; i < user_address_.length; i++) {
            ITRC202.UserNftObj[] memory u = ITRC202(nft).getUserObjList(user_address_[i]);
            uint256 cp = 0;
            for (uint256 j = 0; j < u.length; j++) {
                cp += u[j].energy_value;
            }
            rs[i] = cp;
        }
        return (rs);
    }

}