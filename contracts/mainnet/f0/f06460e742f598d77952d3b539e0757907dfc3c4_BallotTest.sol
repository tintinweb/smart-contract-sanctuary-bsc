/**
 *Submitted for verification at BscScan.com on 2022-09-08
*/

// SPDX-License-Identifier: GPL-3.0

contract BallotTest {

    uint256[10] public a = [0,1,2,3,4,5,6,7,8,9];
    uint256[10] public b = [0,1,2,3,4,5,6,7,8,9];
    uint256[10] public c = [0,1,2,3,4,5,6,7,8,9];

    function test () public view returns (uint,uint) {
        uint e;
        uint f;
        for(uint i=0;i<10;++i) {
            uint A = a[i];
            for(uint m=0;m<10;++m) {
                uint B = b[m];
                for(uint n=0;n<10;++n) {
                    uint C = c[n];
                    uint D = A+B+C;
                    if (D>=14) e +=1;
                    else f +=1;
                }
            }
        }
        return (e,f);
    }
}