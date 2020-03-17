function car_rental3()
clc
% % load('dP_test','P');
% % load('dR_test','R');

load('dP','P');
load('dR','R');

method=1;

if method==1%%%%%%POLICY ITERATION   
    [Policy,Value,run_time,Ext_iter_num,total_iter]=policy_iteration(P,R)
    save('dPol_method1','Policy');
    save('dV_method1','Value');
    plot_Polresult(Policy);
    plot_Valresult(Value);
elseif method==2 %%%VALUE ITERATION
    [Policy,Value,run_time,iter_num]=value_iteration(P,R)
    save('dPol_method2','Policy');
    save('dV_method2','Value');
    plot_Polresult2(Policy);
    plot_Valresult(Value);
    
end


end


%% VALUE ITERATION
function [action_selected,V,run_time,iter_num]=value_iteration(P,R)
global all_state1;
global all_state2;
global all_action;
[policy,V,Q,delta,theta,gama]=Init();
action_selected=zeros(all_state1*all_state2);
[policy,V,Q,delta,theta,gama]=Init();
iter_num=0;
t = cputime;
while delta>=theta
    iter_num=iter_num+1;
    delta=0;
    for state=1:all_state1*all_state2
        prev_v=V(state);
        for action=1:all_action
            sum=0;
            for next_state=1:all_state1*all_state2
                if P(state,next_state,action)~=0
                    sum=sum+(R(state,next_state,action)+gama*V(next_state))*P(state,next_state,action);
                end
            end
            q(action)=sum;
        end
        [V(state),ind]=max(q);

        action_selected(state)=ind;
%         V(state)=max(q);
        dif=abs(prev_v-V(state));
        if dif>delta
            delta=dif;
        end

    end
    %     V
end
run_time = cputime-t;
save('dA','action_selected');
end


%% POLICY ITERATION
function [policy,V,run_time,Ext_iter_num,total_iter]=policy_iteration(P,R)
stable=0;
[policy,V,Q,delta,theta,gama]=Init();
Ext_iter_num=0;
Int_iter=0;
total_iter=0;
t = cputime;
while stable==0   
    Ext_iter_num=Ext_iter_num+1;
    total_iter=total_iter+Int_iter;
    [Q,V,Int_iter]=policy_evaluation(P,R,policy,V,Q,delta,theta,gama);
    old_policy=policy;
    [policy]=policy_improvement(Q,policy,P,R,gama,V);
    if old_policy==policy
        stable=1;
    end
%     plot_result(policy,V);
end
run_time = cputime-t;
% V
% policy
end

%% POLICY EVALUATION
function [Q,V,Int_iter]=policy_evaluation(P,R,policy,V,Q,delta,theta,gama)
global all_state1;
global all_state2;
global all_action;
% % Q=zeros(all_state1*all_state2,all_action,all_action);
Int_iter=0;
while delta>theta
    Int_iter=Int_iter+1;
    delta=0;
    Prev_V=V;
    for state=1:all_state1*all_state2
        prev_v=Prev_V(state);
%         %         Q=zeros(all_state1*all_state2,all_action,all_action);
        v_new=0;
        for action=1:all_action
            sum=0;
            for next_state=1:all_state1*all_state2
                if P(state,next_state,action)~=0
%                     %                     Q(state,action)=Q(state,action)+(R(state,next_state,action)+gama*V(next_state))*P(state,next_state,action);
                    sum=sum+(R(state,next_state,action)+gama*Prev_V(next_state))*P(state,next_state,action);
                end
            end
            Q(state,action)=sum;
%             %             V(state)=V(state)+policy(state,action)*Q(state,action);
%             v_new=v_new+policy(state,action)*Q(state,action);
            v_new=v_new+policy(state,action)*sum;

        end
        V(state)=v_new;
        dif=abs(prev_v-V(state));
        if dif>delta
            delta=dif;
        end

    end
    %     V
end

end

%% POLICY IMPROVEMENT
function  [policy]=policy_improvement(Q,policy,P,R,gama,V)
global all_state1;
global all_state2;
global all_action;

for state=1:1:all_state1*all_state2
%     %     [val,max_a]=max(Q(s,:));
    for action=1:all_action
        sum=0;
        for next_state=1:all_state1*all_state2
            if P(state,next_state,action)~=0
                sum=sum+(R(state,next_state,action)+gama*V(next_state))*P(state,next_state,action);
            end
        end
        q(action)=sum;
    end

        [val,max_a]=max(q);
        policy(state,:)=0;
        policy(state,max_a)=1;


%     [max_q,max_a]=max(q);
%     ind=find(q==max_q);
%     si=size(ind);
%     new_p=1/si(2);
%     policy(state,:)=0;
%     for i=1:si(2)
%         policy(state,ind(i))=new_p;
%     end
end
end

%% SHOW BEST POLICY IN EACH STATE
function plot_Polresult(pol)
global all_state1;
global all_state2;
global all_action;
res=zeros(all_state1,all_state2);
for a=1:all_action
    for s=1:all_state1*all_state2
        if pol(s,a)==1
            row=floor((s-1)/21);
            col=mod(s-1,21);
            res(row+1,col+1)=a;
        end
    end
    
end

figure
pcolor(res)
% res
end

function plot_Polresult2(pol)
global all_state1;
global all_state2;

res=zeros(all_state1,all_state2);
% load('dA','action_selected');
% pol=action_selected;
for s=1:21*21
            row=floor((s-1)/21);
            col=mod(s-1,21);

            res(row+1,col+1)=pol(s);   
end
figure
pcolor(res)
% res
end

function plot_Valresult(val)
global all_state1;
global all_state2;
figure
s=1:all_state1*all_state2;
x=ceil(s/all_state1);
y=mod(s,all_state2);
[X,Y]=meshgrid(x,y);
surf(X,Y, val((X-1)*21+Y+1))
end

%% INITIALIZATION
function [policy,V,Q,delta,theta,gama]=Init()
global all_state1;
global all_state2;
global all_action;
all_state1=21;
all_state2=21;
all_action=11;
%arbitrary initial policy
for s=1:all_state1*all_state2
    prob=rand(1,11);
    policy(s,:)=prob/sum(prob);
end

% policy=zeros(all_state1*all_state2,all_action);
% policy(:,6)=1;

V=50*ones(1,all_state1*all_state2);
% V=zeros(1,all_state1*all_state2);
Q=zeros(all_state1*all_state2,all_action);

delta=100;
theta=0.01;
% gama=0.6;
gama=0.9;
end

