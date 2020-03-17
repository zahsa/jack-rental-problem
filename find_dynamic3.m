% function [P,R]=find_dynamic3()
clear all
all_state1=21;
all_state2=21;
all_action=11;
repetion=1000;

Num=zeros(1,all_state1*all_state2);
Reward=zeros(1,all_state1*all_state2);
P=zeros(all_state1*all_state2,all_state1*all_state2,all_action);
R=zeros(all_state1*all_state2,all_state1*all_state2,all_action);

for s=1:all_state1*all_state2
    state.n1=floor((s-1)/all_state1);
    state.n2=mod(s-1,all_state2);
    for action=-5:5
        Num=zeros(1,all_state1*all_state2);
        Reward=zeros(1,all_state1*all_state2);
        for rep=1:repetion
            [next_state,rwrd]=rental_day(state,action,810188447);
            Num(next_state.n1*21+next_state.n2+1)=Num(next_state.n1*21+next_state.n2+1)+1;
            Reward((next_state.n1)*21+next_state.n2+1)=Reward(next_state.n1*21+next_state.n2+1)+rwrd;
        end

        P(s,:,action+6)=Num/repetion;
        R(s,:,action+6)=Reward./Num;
    end
end

save('dP','P');
save('dR','R');