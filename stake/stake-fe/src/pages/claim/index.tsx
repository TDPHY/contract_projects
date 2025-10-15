import { Box, Typography, Button, Grid } from "@mui/material";
import { NextPage } from "next";
import { useStakeContract } from "../../hooks/useContract";
import { useCallback, useEffect, useState } from "react";
import { Pid } from "../../utils";
import { useAccount, useWalletClient } from "wagmi";
import { formatUnits } from "viem";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { LoadingButton } from "@mui/lab";
import { waitForTransactionReceipt } from "viem/actions";
import { toast } from "react-toastify";
import Header from "../../components/Header";

export type UserRewardData = {
  staked: string;
  pendingReward: string;
  totalClaimed: string;
}

const InitData = {
  staked: '0',
  pendingReward: '0',
  totalClaimed: '0'
}

const Claim: NextPage = () => {
  const stakeContract = useStakeContract()
  const { address, isConnected } = useAccount()
  const [claimLoading, setClaimLoading] = useState(false)
  const { data } = useWalletClient()
  const [userData, setUserData] = useState<UserRewardData>(InitData)

  const getUserData = useCallback(async () => {
    if (!stakeContract || !address) return;
    
    try {
      const staked = await stakeContract?.read.stakingBalance([Pid, address])
      const pendingReward = await stakeContract?.read.pendingMetaNode([Pid, address])
      
      setUserData({
        staked: formatUnits(staked as bigint, 18),
        pendingReward: formatUnits(pendingReward as bigint, 18),
        totalClaimed: '0' // 需要从事件中获取历史领取记录
      })
    } catch (error) {
      console.error('Error fetching user data:', error)
    }
  }, [stakeContract, address])

  useEffect(() => {
    if (stakeContract && address) {
      getUserData()
    }
  }, [stakeContract, address, getUserData])

  const handleClaim = async () => {
    if (!stakeContract || !data) return;
    
    try {
      setClaimLoading(true)
      const tx = await stakeContract.write.claim([Pid])
      const res = await waitForTransactionReceipt(data, { hash: tx })
      toast.success('Reward claimed successfully!')
      setClaimLoading(false)
      getUserData() // 刷新数据
    } catch (error: any) {
      setClaimLoading(false)
      console.error('Claim error:', error)
      toast.error(error?.shortMessage || 'Failed to claim reward')
    }
  }

  const hasRewards = Number(userData.pendingReward) > 0

  return (
    <>
      <Header />
      <Box display={'flex'} flexDirection={'column'} alignItems={'center'} width={'100%'} minHeight={'80vh'}>
        <Typography sx={{ fontSize: '30px', fontWeight: 'bold', mt: 4 }}>Claim Rewards</Typography>
        <Typography sx={{ color: '#666', mb: 4 }}>Claim your MetaNode token rewards</Typography>
        
        <Box sx={{ 
          border: '1px solid #eee', 
          borderRadius: '12px', 
          p: '30px', 
          width: '600px', 
          backgroundColor: '#fafafa'
        }}>
          <Grid container spacing={3} sx={{ mb: 4 }}>
            <Grid item xs={6}>
              <Box display={'flex'} flexDirection={'column'} alignItems={'center'}>
                <Typography variant="body2" color="textSecondary" sx={{ mb: 1 }}>
                  Staked Amount
                </Typography>
                <Typography variant="h6" fontWeight="bold">
                  {userData.staked} ETH
                </Typography>
              </Box>
            </Grid>
            <Grid item xs={6}>
              <Box display={'flex'} flexDirection={'column'} alignItems={'center'}>
                <Typography variant="body2" color="textSecondary" sx={{ mb: 1 }}>
                  Pending Rewards
                </Typography>
                <Typography variant="h6" fontWeight="bold" color="primary">
                  {userData.pendingReward} MetaNode
                </Typography>
              </Box>
            </Grid>
          </Grid>

          <Box sx={{ 
            backgroundColor: hasRewards ? '#e8f5e8' : '#f5f5f5', 
            p: 3, 
            borderRadius: '8px',
            mb: 3
          }}>
            <Typography variant="h6" sx={{ mb: 2 }}>
              {hasRewards ? '🎉 Rewards Available!' : 'No Rewards Available'}
            </Typography>
            <Typography variant="body2" color="textSecondary">
              {hasRewards 
                ? `You have ${userData.pendingReward} MetaNode tokens ready to claim.`
                : 'Stake ETH to start earning MetaNode token rewards.'
              }
            </Typography>
          </Box>

          <Box display={'flex'} justifyContent={'center'}>
            {!isConnected ? (
              <ConnectButton />
            ) : (
              <LoadingButton
                variant="contained"
                size="large"
                loading={claimLoading}
                onClick={handleClaim}
                disabled={!hasRewards}
                sx={{
                  minWidth: '200px',
                  backgroundColor: hasRewards ? '#1976d2' : '#ccc',
                  '&:hover': {
                    backgroundColor: hasRewards ? '#1565c0' : '#ccc'
                  }
                }}
              >
                {hasRewards ? 'Claim Rewards' : 'No Rewards'}
              </LoadingButton>
            )}
          </Box>
        </Box>

        <Box sx={{ mt: 4, p: 3, backgroundColor: '#fff3cd', borderRadius: '8px', maxWidth: '600px' }}>
          <Typography variant="body2" color="#856404">
            💡 Tip: You can claim rewards at any time. Claiming doesn't affect your staked amount.
          </Typography>
        </Box>
      </Box>
    </>
  )
}

export default Claim