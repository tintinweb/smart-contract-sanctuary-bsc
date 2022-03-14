/**
 *Submitted for verification at BscScan.com on 2022-03-14
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

interface IERC20 {

}
contract SuvHelper {
    struct PoolData {
        uint256 pid;
        bytes data;
        IERC20 lpToken; // 池子是哪种lp.
        uint256 allocPoint; // How many allocation points assigned to this pool. SUSHIs to distribute per block.
        uint256 amount; // 用户存的数量
        bool isNFT; // NFT flags.
        uint256 withdrawFee; // User withdraw fee
        uint256 minAmount; // ETH/Token min value
        uint256 lastRewardTime; // 最后奖励时间
        uint256 accSushiPerShare; // Accumulated SUSHIs per share, times 1e12. See below.
    }
    //PoolData[] public poolInfo;
    bytes4 public constant PoolInfoSel = bytes4(keccak256(bytes('poolInfo(uint256)')));

    function poolInfo(address masterchef_, uint256[] memory pids_)
        public view returns (PoolData[] memory)
    {
	    PoolData [] memory p = new PoolData[](pids_.length);
        for (uint256 i = 0; i < pids_.length; i++) {
            p[i] = poolInfoOne(masterchef_, pids_[i]);
        }
        return p;
    }
    function poolInfoOne(address masterchef_, uint256 pid_) public view returns (PoolData memory) {
        return _poolInfo(masterchef_, PoolInfoSel, pid_, 0, 32, 64, 128,160,192,224);
    }

  // 
  // lpToken : address
  // allocPoint: uint256
  // amount: uint256
      function _poolInfo(address masterchef_, bytes4 sel_, uint256 pid_,
                          uint256 rpos0_, uint256 rpos1_, uint256 rpos2_,  uint256 rpos4_,uint256 rpos5_,uint256 rpos6_,uint256 rpos7_)
      public view returns (PoolData memory p)
    {
      (bool success, bytes memory data) = masterchef_.staticcall(abi.encodeWithSelector(sel_, pid_));
      p.pid = pid_;
      p.data = data;
      if (success) {
          p.lpToken = IERC20(toAddress(data, rpos0_));
          p.allocPoint = toUint256(data, rpos1_);
          p.amount = toUint256(data, rpos2_);
          //p.isNFT = toUint256(data, rpos3_);
          p.withdrawFee = toUint256(data, rpos4_);
          p.minAmount = toUint256(data, rpos5_);
          p.lastRewardTime = toUint256(data, rpos6_);
          p.accSushiPerShare = toUint256(data, rpos7_);
      }
  }




    function toAddress(bytes memory _bytes, uint256 _start) public pure returns (address) {
        if (_bytes.length < _start + 20) return address(0);
        address tempAddress;
        assembly {
            tempAddress := mload(add(add(_bytes, 0x20), _start))
        }
        return tempAddress;
    }
    function toUint256(bytes memory _bytes, uint256 _start) public pure returns (uint256) {
        if (_bytes.length < _start + 32) return 0;
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }
    function toBool(bytes memory _bytes, uint256 _start) public pure returns (bool) {
        //if (_bytes.length < _start + 2) return false;
        bool tempBool;
        assembly {
            tempBool := mload(add(add(_bytes, 0x20), _start))
        }
        return tempBool;
    }
}