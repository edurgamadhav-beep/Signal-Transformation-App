classdef SignalTransformApp < handle
    % SignalTransformApp  Time shifting, scaling and reversal demo.
    % Run with: app = SignalTransformApp;

    properties
        UIFigure
        MainGrid
        LeftPanel
        CenterPanel
        RightPanel
        LeftGrid
        CenterGrid
        RightGrid
        SignalDropDown
        EquationField
        ApplyFunctionButton
        OriginalAxes
        TransformedAxes
        InfoLabel
        SummaryLabel
        ScaleField
        ShiftSlider
        ShiftValueLabel
        ReverseCheckBox
        ResetButton
        ExportButton
        CautionLabel
    end
    properties (Access = private)
        T
        X
        SignalName = 'Unit Step'
        ScaleValue = 1.5
        ShiftValue = 2
        IsReversed = false
    end

    methods
        function app = SignalTransformApp
            app.createComponents();
            app.refreshPlots();
        end
        function delete(app)
            if ~isempty(app.UIFigure) && isvalid(app.UIFigure), delete(app.UIFigure); end
        end
    end
    methods (Access = private)
        function createComponents(app)
            bg = [0.97 0.98 1.00]; blue = [0.14 0.31 0.57];
            app.UIFigure = uifigure('Name','Time Shifting, Time Scaling and Time Reversal in Signal Processing', ...
                'Position',[80 60 1450 900],'Color',bg);
            app.MainGrid = uigridlayout(app.UIFigure,[2 3]);
            app.MainGrid.RowHeight = {'1x',42}; app.MainGrid.ColumnWidth = {290,'1x',330};
            app.MainGrid.Padding = [12 12 12 10]; app.MainGrid.RowSpacing = 10; app.MainGrid.ColumnSpacing = 12;
            app.LeftPanel = uipanel(app.MainGrid,'Title','1. Select Signal','FontWeight','bold','ForegroundColor',blue);
            app.LeftPanel.Layout.Row=1; app.LeftPanel.Layout.Column=1;
            app.CenterPanel = uipanel(app.MainGrid,'Title','','BorderType','line');
            app.CenterPanel.Layout.Row=1; app.CenterPanel.Layout.Column=2;
            app.RightPanel = uipanel(app.MainGrid,'Title','2. Choose Operation(s)','FontWeight','bold','ForegroundColor',blue);
            app.RightPanel.Layout.Row=1; app.RightPanel.Layout.Column=3;
            app.LeftGrid=uigridlayout(app.LeftPanel,[8 1]); app.LeftGrid.RowHeight={34,34,34,34,34,80,'1x',74};
            app.LeftGrid.Padding=[12 12 12 12]; app.LeftGrid.RowSpacing=8;
            app.SignalDropDown=uidropdown(app.LeftGrid,'Items',{'Unit Step','Impulse','Ramp','Signum','Triangular','Rectangular','User Defined'}, ...
                'Value','User Defined','ValueChangedFcn',@app.SignalDropDownValueChanged);
            app.SignalDropDown.Layout.Row=1;
            lbl=uilabel(app.LeftGrid,'Text','User Defined Function','FontWeight','bold','FontColor',blue); lbl.Layout.Row=2;
            hint=uilabel(app.LeftGrid,'Text','Enter equation in terms of t:','WordWrap','on'); hint.Layout.Row=3;
            app.EquationField=uieditfield(app.LeftGrid,'text','Value','sin(2*pi*t).*exp(-0.2*abs(t))'); app.EquationField.Layout.Row=4;
            ex=uilabel(app.LeftGrid,'Text',{'Examples: sin(2*pi*t), cos(t), exp(-t.^2),'; '(t.^2).*u(t-1), sin(t)./t'},'WordWrap','on','FontColor',blue); ex.Layout.Row=5;
            app.ApplyFunctionButton=uibutton(app.LeftGrid,'Text','Apply Function','ButtonPushedFcn',@app.ApplyFunctionButtonPushed); app.ApplyFunctionButton.Layout.Row=6;
            spacer=uilabel(app.LeftGrid,'Text',''); spacer.Layout.Row=7;
            note=uilabel(app.LeftGrid,'Text',{'Note:','Use ''t'' as the independent variable.','u(t) is the unit step function.'}, ...
                'WordWrap','on','BackgroundColor',[1.00 0.97 0.87]); note.Layout.Row=8;

            app.CenterGrid=uigridlayout(app.CenterPanel,[3 1]); app.CenterGrid.RowHeight={'1x','1x',125};
            app.CenterGrid.Padding=[8 8 8 8]; app.CenterGrid.RowSpacing=6;
            app.OriginalAxes=uiaxes(app.CenterGrid); app.OriginalAxes.Layout.Row=1;
            app.TransformedAxes=uiaxes(app.CenterGrid); app.TransformedAxes.Layout.Row=2;
            infogrid=uigridlayout(app.CenterGrid,[1 2]); infogrid.Layout.Row=3; infogrid.ColumnWidth={'1x','1x'};
            p1=uipanel(infogrid,'Title','Signal Information','FontWeight','bold','ForegroundColor',blue); p1.Layout.Column=1;
            p2=uipanel(infogrid,'Title','Transformation Summary','FontWeight','bold','ForegroundColor',[0.15 0.48 0.27]); p2.Layout.Column=2;
            app.InfoLabel=uilabel(p1,'Position',[10 8 290 78],'WordWrap','on','Text','');
            app.SummaryLabel=uilabel(p2,'Position',[10 8 310 78],'WordWrap','on','Text','');

            app.RightGrid=uigridlayout(app.RightPanel,[12 1]); app.RightGrid.RowHeight={28,30,22,35,22,35,25,28,34,36,34,36};
            app.RightGrid.Padding=[12 10 12 10]; app.RightGrid.RowSpacing=5;
            h=uilabel(app.RightGrid,'Text','Time Scaling','FontWeight','bold','FontColor',blue); h.Layout.Row=1;
            tx=uilabel(app.RightGrid,'Text','Scaling factor (a):'); tx.Layout.Row=2;
            app.ScaleField=uieditfield(app.RightGrid,'numeric','Value',1.5,'Limits',[-10 10], ...
                'ValueChangedFcn',@app.ScaleFieldValueChanged); app.ScaleField.Layout.Row=3;
            lab=uilabel(app.RightGrid,'Text','a must be non-zero. a > 1 compresses; 0 < a < 1 expands.','WordWrap','on','FontColor',blue); lab.Layout.Row=4;
            h=uilabel(app.RightGrid,'Text','Time Shifting','FontWeight','bold','FontColor',blue); h.Layout.Row=5;
            app.ShiftValueLabel=uilabel(app.RightGrid,'Text','Shift amount (t₀): 2.0','FontColor',[0.15 0.48 0.27]); app.ShiftValueLabel.Layout.Row=6;
            app.ShiftSlider=uislider(app.RightGrid,'Limits',[-10 10],'Value',2,'MajorTicks',-10:2.5:10, ...
                'ValueChangingFcn',@app.ShiftSliderValueChanging,'ValueChangedFcn',@app.ShiftSliderValueChanged); app.ShiftSlider.Layout.Row=7;
            h=uilabel(app.RightGrid,'Text','Time Reversal','FontWeight','bold','FontColor',blue); h.Layout.Row=8;
            app.ReverseCheckBox=uicheckbox(app.RightGrid,'Text','Activate Time Reversal   y(t) = x(-t)', ...
                'ValueChangedFcn',@app.ReverseCheckBoxValueChanged); app.ReverseCheckBox.Layout.Row=9;
            app.ResetButton=uibutton(app.RightGrid,'Text','↻   Reset All','ButtonPushedFcn',@app.ResetButtonPushed); app.ResetButton.Layout.Row=10;
            app.ExportButton=uibutton(app.RightGrid,'Text','▣   Export Plot','ButtonPushedFcn',@app.ExportButtonPushed); app.ExportButton.Layout.Row=11;
            extra=uilabel(app.RightGrid,'Text','Transform rule: y(t) = x(a(t − t₀))','WordWrap','on','FontColor',blue); extra.Layout.Row=12;
            app.CautionLabel=uilabel(app.MainGrid,'Text','⚠  Caution: Scaling factor cannot be zero. Please enter a non-zero value.', ...
                'FontWeight','bold','BackgroundColor',[1.00 0.97 0.87],'HorizontalAlignment','left');
            app.CautionLabel.Layout.Row=2; app.CautionLabel.Layout.Column=[1 3];
            app.T=linspace(-10,10,2001); app.makeSignal('User Defined');
        end
        function makeSignal(app,name)
            t=app.T;
            switch name
                case 'Unit Step', x=double(t>=0);
                case 'Impulse', x=zeros(size(t)); x(abs(t)<0.051)=1; % sampled impulse display
                case 'Ramp', x=max(t,0);
                case 'Signum', x=sign(t);
                case 'Triangular', x=max(1-abs(t),0);
                case 'Rectangular', x=double(abs(t)<=1);
                otherwise
                    u=@(z) double(z>=0); %#ok<NASGU> unit step helper for custom expressions
                    f=eval(['@(t) ' app.EquationField.Value]);
                    x=f(t); if isscalar(x), x=repmat(x,size(t)); end
                    if ~isequal(size(x),size(t)), error('Function must return one value per sample.'); end
                    x=double(x);
            end
            if any(~isfinite(x)), error('Function produced non-finite values.'); end
            app.X=x; app.SignalName=name;
        end
        function refreshPlots(app)
            plot(app.OriginalAxes,app.T,app.X,'Color',[0.16 0.34 0.65],'LineWidth',1.5);
            title(app.OriginalAxes,'Original Signal x(t)','Color',[0.16 0.34 0.65]); xlabel(app.OriginalAxes,'Time (t)'); ylabel(app.OriginalAxes,'Amplitude');
            xlim(app.OriginalAxes,[-10 10]); grid(app.OriginalAxes,'on'); app.OriginalAxes.FontSize=10;
            q=app.ScaleValue*(app.T-app.ShiftValue); if app.IsReversed, q=-q; end
            y=interp1(app.T,app.X,q,'linear',0);
            plot(app.TransformedAxes,app.T,y,'Color',[0.12 0.48 0.25],'LineWidth',1.5);
            title(app.TransformedAxes,'Transformed Signal y(t)','Color',[0.12 0.48 0.25]); xlabel(app.TransformedAxes,'Time (t)'); ylabel(app.TransformedAxes,'Amplitude');
            xlim(app.TransformedAxes,[-10 10]); grid(app.TransformedAxes,'on'); app.TransformedAxes.FontSize=10;
            app.InfoLabel.Text=sprintf('Signal Type  : %s\nTime Range   : -10 to 10\nNo. of Points: %d\nSampling Interval (dt): %.3f',app.SignalName,numel(app.T),app.T(2)-app.T(1));
            ops={}; if app.ScaleValue~=1, ops{end+1}='Time Scaling'; end
            if app.ShiftValue~=0, ops{end+1}='Time Shifting'; end
            if app.IsReversed, ops{end+1}='Time Reversal'; end
            if isempty(ops), ops={'None'}; end
            app.SummaryLabel.Text=sprintf('Operation(s): %s\nScaling Factor (a): %.3g\nTime Shift (t₀): %.3g\nTime Reversal: %s',strjoin(ops,', '),app.ScaleValue,app.ShiftValue,mat2str(app.IsReversed));
        end
        function showError(app,msg)
            app.CautionLabel.Text=['⚠  Caution: ' msg]; app.CautionLabel.BackgroundColor=[1.00 0.90 0.88];
        end
        function clearCaution(app)
            app.CautionLabel.Text='⚠  Caution: Scaling factor cannot be zero. Please enter a non-zero value.';
            app.CautionLabel.BackgroundColor=[1.00 0.97 0.87];
        end
        function SignalDropDownValueChanged(app,~,~)
            try
                if strcmp(app.SignalDropDown.Value,'User Defined'), app.makeSignal('User Defined'); else, app.makeSignal(app.SignalDropDown.Value); end
                app.clearCaution(); app.refreshPlots();
            catch e, app.showError(e.message); end
        end
        function ApplyFunctionButtonPushed(app,~,~)
            try, app.makeSignal('User Defined'); app.SignalDropDown.Value='User Defined'; app.clearCaution(); app.refreshPlots();
            catch e, app.showError(['Invalid equation. ' e.message]); end
        end
        function ScaleFieldValueChanged(app,~,~)
            if app.ScaleField.Value==0, app.showError('Scaling factor cannot be zero. Enter a non-zero value.'); app.ScaleField.Value=app.ScaleValue; return; end
            app.ScaleValue=app.ScaleField.Value; app.clearCaution(); app.refreshPlots();
        end
        function ShiftSliderValueChanging(app,evt,~), app.ShiftValue=evt.Value; app.ShiftValueLabel.Text=sprintf('Shift amount (t₀): %.1f',evt.Value); app.refreshPlots(); end
        function ShiftSliderValueChanged(app,evt,~), app.ShiftValue=evt.Value; app.ShiftValueLabel.Text=sprintf('Shift amount (t₀): %.1f',evt.Value); app.refreshPlots(); end
        function ReverseCheckBoxValueChanged(app,~,~), app.IsReversed=app.ReverseCheckBox.Value; app.refreshPlots(); end
        function ResetButtonPushed(app,~,~)
            app.ScaleValue=1.5; app.ShiftValue=0; app.IsReversed=false; app.ScaleField.Value=1.5;
            app.ShiftSlider.Value=0; app.ReverseCheckBox.Value=false; app.ShiftValueLabel.Text='Shift amount (t₀): 0.0';
            app.SignalDropDown.Value='User Defined'; app.makeSignal('User Defined'); app.clearCaution(); app.refreshPlots();
        end
        function ExportButtonPushed(app,~,~)
            [f,p]=uiputfile({'*.png';'*.jpg';'*.pdf'},'Export transformed plot','signal_transform.png'); if isequal(f,0), return; end
            try, exportgraphics(app.CenterPanel,fullfile(p,f)); app.clearCaution();
            catch e, app.showError(['Export failed. ' e.message]); end
        end
    end
end
